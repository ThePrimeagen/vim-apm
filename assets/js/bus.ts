export interface EventMap {
    progress_complete: {};
}

type EventName = keyof EventMap;
type EventData<T extends EventName> = EventMap[T];
type EventListener<T extends EventName> = (data: EventData<T>) => void;

class EventBus {
    private listeners: Map<EventName, EventListener<any>[]> = new Map();

    emit<T extends EventName>(name: T, data: EventData<T>): void {
        const eventListeners = this.listeners.get(name);
        if (eventListeners) {
            eventListeners.forEach((listener) => listener(data));
        }
    }

    listen<T extends EventName>(
        name: T,
        listener: EventListener<T>,
    ) {
        if (!this.listeners.has(name)) {
            this.listeners.set(name, []);
        }

        this.listeners.get(name)!.push(listener);
    }
}

export const eventBus = new EventBus();
export default eventBus;
