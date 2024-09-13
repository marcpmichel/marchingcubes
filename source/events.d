module events;

enum EventType { Scene, ClearColor }

struct UIEvent {
    EventType type;
    string data;
}
