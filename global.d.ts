// Global type definitions for JSDoc usage

declare global {
    type ModeMap = {
        n: number;
        i: number;
        v: number;
        untracked: number;
    };
    type APMVimMotion = {
        type: "motion";
        value: {
            chars: string;
            timings: number[];
        };
    };

    type APMVimModeTimes = {
        type: "mode_times";
        value: ModeMap;
    };

    type APMVimWrite = {
        type: "write";
    };

    type APMVimBufEnter = {
        type: "buf_enter";
    };

    type APMVimApmReport = {
        type: "apm_report";
        value: {
            apm: number;
            mode_timings: ModeMap;
        };
    };

    type APMVimStateChange = {
        type: "apm_state_change";
        value: {
            from: string,
            time: number,
        };
    };

    type APMServerMessage =
        | APMVimMotion
        | APMVimWrite
        | APMVimBufEnter
        | APMVimApmReport
        | APMVimModeTimes;

    type APMEvent = {
        type: "server-message";
        message: APMServerMessage[];
    };

    type UIMotion = {
        chars: string;
        display_chars?: string;
        count: number;
    };

    type Level = {
        level: number;
        apm: number;
        modes: ModeMap;
        progress: number;
        last_update: number;
        last_set_progress: number;
        last_motion_executed: UIMotion;
    };
}

export {};
