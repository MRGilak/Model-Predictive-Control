classdef EPFCController < handle
    properties
        linearization_method
        Ts
        N_model
        mu
        m
        q
        r
        psi
        u_min
        u_max
        beta
        Ni
        TOL
        is_programmed_ref

        linearize_fn
        step_response_fn
        model_step_fn

        v_prev
        y_pred
        u_prev
    end

    methods
        function obj = EPFCController(config)
            obj.linearization_method = config.linearization_method;
            obj.Ts = config.Ts;
            obj.N_model = config.N_model;
            obj.mu = config.mu(:)';
            obj.m = config.m(:)';
            obj.q = config.q(:)';
            obj.r = config.r(:)';
            obj.psi = config.psi(:)';
            obj.u_min = config.u_min;
            obj.u_max = config.u_max;
            obj.beta = config.beta;
            obj.Ni = config.Ni;
            obj.TOL = config.TOL;

            if isfield(config, 'is_programmed_ref')
                obj.is_programmed_ref = config.is_programmed_ref;
            else
                obj.is_programmed_ref = false;
            end

            if isfield(config, 'linearize_fn')
                obj.linearize_fn = config.linearize_fn;
            else
                obj.linearize_fn = @systems.model.epfc.linearize_dynamics;
            end

            if isfield(config, 'step_response_fn')
                obj.step_response_fn = config.step_response_fn;
            else
                obj.step_response_fn = @systems.model.epfc.get_step_response_nonlinear;
            end

            if isfield(config, 'model_step_fn')
                obj.model_step_fn = config.model_step_fn;
            else
                obj.model_step_fn = @systems.model.epfc.update_nonlinear_state;
            end

            obj.v_prev = 0;
            obj.u_prev = config.u0;
            obj.y_pred = config.x0(1);
        end

        function [u_next, info] = step(obj, x_model, y_current, ref_now, ref_future)
            x1_prev = x_model(1);
            obj.u_prev = -x1_prev + obj.v_prev;

            if strcmp(obj.linearization_method, 'jacobian')
                C = [1, 0];
                [A, B] = obj.linearize_fn(x_model, obj.Ts);
                sys_d = ss(A, B, C, 0, obj.Ts);
                sr_all = step(sys_d, (0:obj.N_model) * obj.Ts);
                step_response = sr_all(1:end);
            elseif strcmp(obj.linearization_method, 'perturbation')
                step_response = obj.step_response_fn(x_model, obj.u_prev, obj.Ts, obj.N_model);
            else
                error('Unknown linearization method');
            end

            G = obj.build_dynamic_matrix(step_response);
            Tmat = obj.build_dynamic_matrix(step_response);

            Ypast = zeros(max(obj.mu), 1);
            x_tmp = x_model;
            for t = 1:max(obj.mu)
                u_sim = -x_tmp(1) + obj.v_prev;
                x_tmp = obj.model_step_fn(x_tmp, u_sim, obj.Ts);
                Ypast(t) = x_tmp(1);
            end

            if obj.is_programmed_ref
                Yd = zeros(1, numel(obj.mu));
                for i = 1:numel(obj.mu)
                    idx = obj.mu(i);
                    if idx <= numel(ref_future)
                        ref_val = ref_future(idx);
                    else
                        ref_val = ref_future(end);
                    end
                    Yd(i) = obj.psi(i) * y_current + (1 - obj.psi(i)) * ref_val;
                end
            else
                Yd = obj.psi .* y_current + (1 - obj.psi) .* ref_now;
            end

            Ym = Ypast(obj.mu);
            d_ext = y_current - obj.y_pred;
            D_ext = d_ext * ones(numel(Ym), 1);

            D_nl = zeros(numel(Ym), 1);
            dv = zeros(numel(obj.m), 1);

            for iter = 1:obj.Ni
                D_total = D_ext + D_nl;
                e = Yd(:) - Ym - D_total;

                Qmat = diag(obj.q);
                Rmat = diag(obj.r);
                H = G' * Qmat * G + Rmat;
                f = -G' * Qmat * e;

                T = tril(ones(numel(obj.m), numel(obj.m)));
                use_constraints = isfinite(obj.u_min) && isfinite(obj.u_max);

                options = optimoptions('quadprog', 'Display', 'off');

                if use_constraints
                    Aineq = [T; -T];
                    bineq = [(obj.u_max + x1_prev - obj.v_prev) * ones(numel(obj.m), 1); ...
                             -(obj.u_min + x1_prev - obj.v_prev) * ones(numel(obj.m), 1)];
                    dv = quadprog(H, f, Aineq, bineq, [], [], [], [], [], options);
                else
                    dv = quadprog(H, f, [], [], [], [], [], [], [], options);
                end

                x_nl_tmp = x_model;
                Y_nl = zeros(numel(obj.mu), 1);
                for i = 1:max(obj.mu)
                    if any(obj.m == (i - 1))
                        delta_idx = find(obj.m == (i - 1));
                        delta_u = dv(delta_idx);
                    else
                        delta_u = 0;
                    end
                    u_sim = -x_nl_tmp(1) + obj.v_prev + delta_u;
                    x_nl_tmp = obj.model_step_fn(x_nl_tmp, u_sim, obj.Ts);
                    if any(obj.mu == i)
                        Y_nl(obj.mu == i) = x_nl_tmp(1);
                    end
                end

                Y_li = Tmat * dv + Ym;
                h = Y_nl - (Y_li + D_nl);
                D_nl_candidate = D_nl + obj.beta * h;

                if norm(D_nl_candidate - D_nl) < obj.TOL
                    D_nl = D_nl_candidate;
                    break;
                end

                D_nl = D_nl_candidate;
            end

            v = obj.v_prev + dv(1);
            u_next = -x_model(1) + v;

            x_pred = obj.model_step_fn(x_model, u_next, obj.Ts);
            obj.y_pred = x_pred(1);
            obj.v_prev = v;
            obj.u_prev = u_next;

            info = struct('dv', dv, 'du', dv(1), 'v', v, 'd_ext', d_ext, 'D_nl', D_nl);
        end
    end

    methods (Access = private)
        function G = build_dynamic_matrix(obj, step_response)
            G = zeros(numel(obj.mu), numel(obj.m));
            for i = 1:numel(obj.mu)
                for j = 1:numel(obj.m)
                    idx = obj.mu(i) - obj.m(j);
                    if idx > 0 && idx <= numel(step_response)
                        G(i, j) = step_response(idx);
                    else
                        G(i, j) = 0;
                    end
                end
            end
        end
    end
end
