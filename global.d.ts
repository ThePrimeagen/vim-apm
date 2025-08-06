// Global type definitions for JSDoc usage

declare global {

    type APMVimMotion = {
        type: "motion",
        value: {
            chars: string,
            timings: number[],
        }
    }

    type APMVimWrite = {
        type: "write",
    }

    type APMVimBufEnter = {
        type: "buf_enter",
    }

    type APMVimApmReport = {
        type: "apm_report",
        value: number
    }

    type APMServerMessage = APMVimMotion | APMVimWrite | APMVimBufEnter | APMVimApmReport

    type APMEvent = {
        type: "server-message",
        message: APMServerMessage[],
    }

    type UIMotion = {
        chars: string,
        display_chars?: string;
        count: number,
    }

    type Level = {
        level: number,
        apm: number,
        progress: number,
        last_update: number,
        last_set_progress: number,
        last_motion_executed: UIMotion,
    }
}

export {};
