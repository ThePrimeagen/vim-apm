// Global type definitions for JSDoc usage

declare global {
  // Add your custom types here
  
  // Example types - remove or modify as needed
  interface VimAPMConfig {
    apiUrl: string;
    debug: boolean;
    reportInterval: number;
  }

  interface MotionData {
    type: string;
    timestamp: number;
    file: string;
    line: number;
    column: number;
  }

  interface StatsData {
    motions: MotionData[];
    sessionTime: number;
    totalKeystrokes: number;
  }

  // Utility types
  type Callback<T = void> = (data: T) => void;
  type Optional<T> = T | null | undefined;
  type StringMap = Record<string, string>;
  type NumberMap = Record<string, number>;
}

export {};