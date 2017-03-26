# Emulate Hash#except from Rails
def hash_except(h, k)
    return h.reject { |kk,vv| kk == k }
end
