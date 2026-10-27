enum kind { K_INT, K_STR };

struct val {
    enum kind k;
    union { int i; const char *s; } u;
};

int val_get_int(const struct val *v) {
    return v->k == K_INT ? v->u.i : -1;
}

const char* val_get_str(const struct val *v) {
    return v->k == K_STR ? v->u.s : "";
}
