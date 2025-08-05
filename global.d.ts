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

    type APMStatsJson = APMVimMotion | APMVimWrite | APMVimBufEnter

    type APMEvent = {
        type: "server-message",
        message: APMStatsJson[],
    }

    type UIMotion = {
        chars: string,
        display_chars?: string;
        count: number,
    }

    type Level = {
        level: number,
        progress: number,
        last_update: number,
        last_set_progress: number,
        last_motion_executed: UIMotion,
    }
}

export {};
