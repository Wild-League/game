--- General stateless utility algorithms
--
-- @module gear.algo
-- @copyright 2022 The DoubleFourteen Code Forge
-- @author Lorenzo Cogotti

local floor = math.floor

local algo = {}


--- Fast remove from array.
--
-- Replace 'array[i]' with last array's element and
-- discard array's tail.
--
-- @tparam table array
-- @int i
function algo.removefast(array, i)
    local n = #array

    array[i] = array[n]  -- NOP if i == n
    array[n] = nil
end

local function lt(a, b) return a < b end

local function _insertionsort(array, lo, hi, less)
    for i = lo+1,hi do
        local k = lo
        local v = array[i]

        for j = i,lo+1,-1 do
          local el = array[j-1]
          if less(v, el) then
              array[j] = el
          else
              k = j
              break
          end
        end
        array[k] = v
    end
end

--- Sort array using Insertion Sort - O(n^2).
--
-- Provides the most basic sorting algorithm around.
-- Performs better than regular table.sort() for small arrays
-- (~100 elements).
--
-- @tparam table array array to be sorted.
-- @tparam[opt=operator <] function less comparison function, takes 2 arguments,
--                                  returns true if its first argument is
--                                  less than its second argument,
--                                  false otherwise.
function algo.insertionsort(array, less)
    _insertionsort(array, 1, #array, less or lt)
end

--- Binary search last element where
--  what <= array[i] - also known as lower bound.
--
-- @tparam table array an array sorted according to the less function.
-- @param what the comparison argument.
-- @tparam[opt=operator <] function less sorting criterium, a function taking 2 arguments,
--                                  returns true if the first argument
--                                  is less than the second argument,
--                                  false otherwise.
--
-- @treturn int the greatest index i, where what <= array[i].
--              If no such element exists, it returns an out of bounds index
--              such that array[i] == nil.
function algo.bsearchl(array, what, less)
    less = less or lt

    local lo, hi = 1, #array
    local ofs, mid = -1, hi

    while mid > 0 do
        mid = floor(hi / 2)

        -- array[lo+mid] <= what <-> what >= array[lo+mid]
        --                       <-> not what < array[lo+mid]
        if not less(what, array[lo+mid]) then
            lo = lo + mid
            ofs = 0  -- at least one element where array[lo+mid] <= what
        end

        hi = hi - mid
    end

    return lo + ofs
end

--- Binary search first element where
--  what >= array[i] - also known as upper bound.
--
-- @tparam table array an array sorted according to the less function.
-- @param what the comparison argument.
-- @tparam[opt=operator <] function less sorting criterium,
--                                  a function taking 2 arguments,
--                                  returns true if the first argument
--                                  is less than the second argument,
--                                  false otherwise.
--
-- @treturn int the smallest index i, where what >= array[i].
--              If no such element exists, it returns an out of bounds index
--              such that array[i] == nil.
function algo.bsearchr(array, what, less)
    less = less or lt

    local lo, hi = 1, #array
    local ofs, mid = -1, hi

    while mid > 0 do
        mid = floor(hi / 2)

        -- array[lo+mid] >= what <-> not array[lo+mid] < what
        if not less(array[lo+mid], what) then
            ofs = 0
        else
            lo = lo + mid
            ofs = 1
        end

        hi = hi - mid
    end

    return lo + ofs
end

local function merge(array, lo, mid, hi, less, workspace)
    local i, j, k
    i = 1

    -- Copy first half of array to auxiliary array
    for j = lo,mid do
        workspace[i] = array[j]
        i = i + 1
    end

    i = 1
    j = mid + 1
    k = lo
    while k < j and j <= hi do
        local v = array[j]
        local el = workspace[i]

        if less(v, el) then
            array[k] = v
            j = j + 1
        else
            array[k] = el
            i = i + 1
        end
        k = k + 1
    end

    -- Copy back any remaining elements of first half
    for k = k,j-1 do
        array[k] = workspace[i]
        i = i + 1
    end
end

local function mergesort(array, lo, hi, less, workspace)
    if hi - lo < 72 then
        _insertionsort(array, lo, hi, less)
    else
        local mid = floor((lo + hi)/2)

        mergesort(array, lo, mid, less, workspace)
        mergesort(array, mid + 1, hi, less, workspace)
        merge(array, lo, mid, hi, less, workspace)
    end
end

--- Array stable sort, uses Merge Sort - O(n*log(n)).
--
-- Algorithm is a slightly altered version of stable_sort(),
-- posted on Lua-L by Steve Fisher on 02 May 2013 22:10:50
-- https://lua-users.org/lists/lua-l/2013-05/msg00038.html
--
-- This implementation uses an auxiliary buffer of size O(n/2).
--
-- @tparam table array Array to be sorted.
-- @tparam[opt=operator <] function less comparison function, takes 2 arguments,
--                                  returns true if its first argument is
--                                  less than its second argument,
--                                  false otherwise.
-- @tparam[opt={}] table use an existing workspace buffer instead of allocating one.
function algo.stablesort(array, less, workspace)
    local n = #array

    less = less or lt
    workspace = workspace or {}
    workspace[floor((n+1)/2)] = array[1]   -- preallocate some room

    mergesort(array, 1, n, less, workspace)
end

return algo
