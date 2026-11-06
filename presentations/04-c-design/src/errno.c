typedef enum {
    ERR_OK = 0,
    ERR_EMPTY,
} err_t;

extern err_t err;

int parse(char *s);

int main(int argc, char **v) {
    int i = parse(v[1]);
    if (err) {
        // process error
        // and discard i (omitted)
    }
}
