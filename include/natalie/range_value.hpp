#pragma once

#include <assert.h>

#include "natalie/class_value.hpp"
#include "natalie/forward.hpp"
#include "natalie/global_env.hpp"
#include "natalie/macros.hpp"
#include "natalie/value.hpp"

namespace Natalie {

struct RangeValue : Value {
    RangeValue(Env *env)
        : Value { Value::Type::Range, env->Object()->const_fetch("Range")->as_class() } { }

    RangeValue(Env *env, ClassValue *klass)
        : Value { Value::Type::Range, klass } { }

    RangeValue(Env *env, ValuePtr begin, ValuePtr end, bool exclude_end)
        : Value { Value::Type::Range, env->Object()->const_fetch("Range")->as_class() }
        , m_begin { begin }
        , m_end { end }
        , m_exclude_end { exclude_end } { }

    ValuePtr begin() { return m_begin; }
    ValuePtr end() { return m_end; }
    bool exclude_end() { return m_exclude_end; }

    ValuePtr initialize(Env *, ValuePtr , ValuePtr , ValuePtr );
    ValuePtr to_a(Env *);
    ValuePtr each(Env *, Block *);
    ValuePtr inspect(Env *);
    ValuePtr eq(Env *, ValuePtr );
    ValuePtr eqeqeq(Env *, ValuePtr );

private:
    ValuePtr m_begin { nullptr };
    ValuePtr m_end { nullptr };
    bool m_exclude_end { false };
};

}
