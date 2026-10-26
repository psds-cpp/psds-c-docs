typedef struct _Window {
    int position;
    const char *title;
} Window;

// эмулируем конструктор из C++
Window default_window(void) {
    Window w = {0, "Window"};
    return w;
}
