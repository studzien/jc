#include "erl_nif.h"
#include <stdio.h>

typedef struct
{
    void* mod_nif;
    void* proc;
} enif_environment_incomplete_t;

void print_memory_info(void* process);

// Prototypes
static ERL_NIF_TERM jc_inspector_inspect(ErlNifEnv* env, int argc,
                                         const ERL_NIF_TERM argv[]);
static ERL_NIF_TERM jc_inspector_word(ErlNifEnv* env, int argc,
                                      const ERL_NIF_TERM argv[]);

static ErlNifFunc nif_funcs[] =
{
    {"inspect", 0, jc_inspector_inspect},
    {"word", 1, jc_inspector_word}
};

static ERL_NIF_TERM jc_inspector_word(ErlNifEnv* env, int argc,
                                           const ERL_NIF_TERM argv[])
{
    unsigned long address;
    if(enif_get_ulong(env, argv[0], &address) == 0) {
        return enif_make_badarg(env);
    }

    unsigned long* ptr = (unsigned long*)address;
    unsigned long value = *ptr;
    return enif_make_ulong(env, value);
}

static ERL_NIF_TERM jc_inspector_inspect(ErlNifEnv* env, int argc,
                                         const ERL_NIF_TERM argv[])
{
    enif_environment_incomplete_t* incomplete_env = (enif_environment_incomplete_t*)env;
    void* process = incomplete_env->proc;
    print_memory_info(process);

    return enif_make_atom(env, "ok");
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info)
{
    return 0;
}

ERL_NIF_INIT(jc_inspector, nif_funcs, &on_load, NULL, NULL, NULL);
