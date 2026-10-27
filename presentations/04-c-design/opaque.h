// forward declaration
struct secret;
typedef struct secret sec_t;

// library API
sec_t *sec_new(int n);
int sec_get(sec_t *s);
