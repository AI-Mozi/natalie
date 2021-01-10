#pragma once

#include <assert.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "natalie/forward.hpp"
#include "natalie/integer_value.hpp"
#include "natalie/nil_value.hpp"
#include "natalie/value.hpp"

namespace Natalie {

struct KernelModule : Value {
    ValuePtr object_id(Env *env) {
        return new IntegerValue { env, Value::object_id() };
    }

    bool equal(ValuePtr other) {
        return this == other;
    }

    ValuePtr klass_obj(Env *env) {
        if (klass()) {
            return klass();
        } else {
            return env->nil_obj();
        }
    }

    ValuePtr singleton_class_obj(Env *env) {
        return singleton_class(env);
    }

    ValuePtr freeze_obj(Env *env) {
        freeze();
        return this;
    }

    ValuePtr Array(Env *env, ValuePtr value);
    ValuePtr at_exit(Env *env, Block *block);
    ValuePtr cur_dir(Env *env);
    ValuePtr define_singleton_method(Env *env, ValuePtr name, Block *block);
    ValuePtr exit(Env *env, ValuePtr status);
    ValuePtr get_usage(Env *env);
    ValuePtr hash(Env *env);
    ValuePtr inspect(Env *env);
    ValuePtr main_obj_inspect(Env *);
    ValuePtr instance_variable_get(Env *env, ValuePtr name_val);
    ValuePtr instance_variable_set(Env *env, ValuePtr name_val, ValuePtr value);
    ValuePtr lambda(Env *env, Block *block);
    ValuePtr loop(Env *env, Block *block);
    ValuePtr methods(Env *env);
    ValuePtr p(Env *env, size_t argc, ValuePtr *args);
    ValuePtr print(Env *env, size_t argc, ValuePtr *args);
    ValuePtr proc(Env *env, Block *block);
    ValuePtr puts(Env *env, size_t argc, ValuePtr *args);
    ValuePtr raise(Env *env, ValuePtr klass, ValuePtr message);
    ValuePtr sleep(Env *env, ValuePtr length);
    ValuePtr spawn(Env *, size_t, ValuePtr *);
    ValuePtr tap(Env *env, Block *block);
    ValuePtr this_method(Env *env);
    bool is_a(Env *env, ValuePtr module);
    bool block_given(Env *env, Block *block) { return !!block; }
};

}
