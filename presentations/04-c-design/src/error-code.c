typedef enum {
    ERR_OK = 0,
    ERR_EMPTY,
} err_t;

err_t parse(int *out,
            char *s);

int main(int argc, char **v) {
    int i = 0;
    if (parse(&i, v[1]) != 0) {
        // process error (omitted)
    }
    return 0;
}
