classdef DMCController < handle
    properties
        p
        m
        a
        Q
        R
        sr
        is_programmed
        is_open_loop
        mode
        Ts
        model_step_fn

        F
        G
        K

        upast
        u
        u_prev
        y_prev
    end

    methods
        function obj = DMCController(config)
            obj.sr = config.sr;
            obj.p = config.p;
            obj.m = config.m;
            obj.a = config.a;
            obj.Q = config.Q(:);
            obj.R = config.R(:);
            obj.is_programmed = config.is_programmed;
            obj.is_open_loop = config.is_open_loop;

            if isfield(config, 'mode')
                obj.mode = config.mode;
            else
                obj.mode = 'linear';
            end

            if isfield(config, 'Ts')
                obj.Ts = config.Ts;
            else
                obj.Ts = [];
            end

            if isfield(config, 'model_step_fn')
                obj.model_step_fn = config.model_step_fn;
            else
                obj.model_step_fn = @systems.model.dmc.update_nonlinear_state;
            end

            n = numel(obj.sr) - obj.p;
            obj.upast = zeros(n, 1);

            step_response = obj.sr(1:n);
            obj.F = hankel(obj.sr(2:obj.p+1), obj.sr(obj.p+1:end)) - repmat(step_response(:)', obj.p, 1);
            obj.G = toeplitz(obj.sr(1:obj.p), obj.sr(1) * eye(1, obj.m));

            Qmat = diag(obj.Q);
            Rmat = diag(obj.R);
            obj.K = (obj.G' * Qmat * obj.G + Rmat) \ (obj.G' * Qmat);

            obj.u = config.u0;
            obj.u_prev = config.u0;

            if isfield(config, 'y0')
                obj.y_prev = config.y0;
            else
                obj.y_prev = 0;
            end
        end

        function [u_next, info] = step(obj, y_measured, ref_window, x_model)
            if nargin < 4
                x_model = [];
            end

            if obj.is_open_loop
                d = 0;
            else
                d = y_measured - obj.y_prev;
            end
            D = ones(obj.p, 1) * d;

            if strcmp(obj.mode, 'linear')
                Ypast = obj.F * obj.upast + y_measured;
            else
                if isempty(obj.Ts)
                    error('Ts must be provided for nonlinear DMC mode.');
                end
                if isempty(x_model)
                    error('x_model must be provided for nonlinear DMC mode.');
                end

                Ypast = zeros(obj.p, 1);
                x_tmp = x_model;
                u_current = obj.u_prev;
                for k = 1:obj.p
                    x_tmp = obj.model_step_fn(x_tmp, u_current, obj.Ts);
                    Ypast(k) = x_tmp(1);
                end
            end

            ref = obj.expand_reference(ref_window);
            w = filter([0 (1 - obj.a)], [1 -obj.a], ref, y_measured);

            Ebar = w - Ypast - D;
            control = obj.K * Ebar;

            du = control(1);
            obj.upast = [du; obj.upast(1:end-1)];
            obj.u = obj.u_prev + du;
            obj.y_prev = Ypast(1) + obj.G(1, 1) * du;
            obj.u_prev = obj.u;

            u_next = obj.u;
            info = struct('du', du, 'd', d, 'Ebar', Ebar, 'w', w, 'Ypast', Ypast);
        end

        function data = internals(obj)
            data = struct('F', obj.F, 'G', obj.G, 'gainMatrix', obj.K(1, :));
        end
    end

    methods (Access = private)
        function ref = expand_reference(obj, ref_window)
            if obj.is_programmed
                number_reference = numel(ref_window);
                if number_reference >= obj.p
                    ref = ref_window(1:obj.p);
                else
                    ref = [ref_window(:); ref_window(end) * ones(obj.p - number_reference, 1)];
                end
            else
                ref = ref_window(1) * ones(obj.p, 1);
            end
        end
    end
end
