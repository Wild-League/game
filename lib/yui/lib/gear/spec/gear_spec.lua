require 'busted.runner'()

describe("gear", function()

    setup(function()
        gear = require 'init'
        algo = gear.algo
        rect = gear.rect
        math = require 'math'
    end)

    describe("insertion sort #sort", function()
        local insertionsort = algo.insertionsort

        it("sorts arrays", function()
            local elems = {}
            local expect = {}

            for n = 2,512 do
                for i = 1,n do
                    elems[i] = math.random(-32768, 32767)
                    expect[i] = elems[i]
                end

                table.sort(expect)
                insertionsort(elems)

                assert.are.same(expect, elems)
            end
        end)

        it("has no effect on single element array", function()

            for i = 1,10 do
                local val = (math.random() - 0.5) * 1024
                local expect = { val }
                local elems = { val }

                insertionsort(elems)

                assert.are.same(expect, elems)
            end
        end)

        it("does nothing on empty array", function()
            local expect = {}
            local elems = {}

            insertionsort(elems)

            assert.are.same(expect, elems)
        end)
    end)

    describe("binary search #bsearch", function()
        local bsearchl = algo.bsearchl
        local bsearchr = algo.bsearchr

        it("behaves properly on empty arrays", function()
            local empty = {}

            local idx = bsearchr(empty, 1)
            assert.is_true(empty[idx] == nil)

            idx = bsearchl(empty, 1)
            assert.is_true(empty[idx] == nil)
        end)

        it("finds elements within sorted arrays", function()
            local dims = { 1, 2, 64, 512, 1024 }

            for _,n in ipairs(dims) do
                local elems = {}

                for i = 1,n do
                    elems[#elems+1] = ((math.random() - 0.5) * 4096)
                end

                local mustfind = {}
                for i = 1,10 do
                    mustfind[#mustfind+1] = elems[math.random(1,#elems)]
                end

                local mustnotfind = {
                     4097,
                    -4097,
                    -math.huge,
                     math.huge,
                     16386,
                    -16386
                }

                table.sort(elems)

                for _,v in ipairs(mustfind) do
                    local idx = bsearchl(elems, v)
                    assert.equal(v, elems[idx])
                    assert.is_false(elems[idx+1] ~= nil and elems[idx+1] <= v)

                    idx = bsearchr(elems, v)
                    assert.equal(v, elems[idx])
                    assert.is_false(elems[idx+1] ~= nil and elems[idx+1] <= v)
                end
                for _,v in ipairs(mustnotfind) do
                    local idx = bsearchl(elems, v)
                    assert.not_equal(v, elems[idx])
                    if v < elems[1] then
                        assert.is_true(elems[idx] == nil)
                    else
                        assert.is_true(elems[idx] <= v)
                    end

                    idx = bsearchr(elems, v)
                    assert.not_equal(v, elems[idx])
                    if v > elems[#elems] then
                        assert.is_true(elems[idx] == nil)
                    else
                        assert.is_true(elems[idx] >= v)
                    end
                end
            end
        end)
    end)

    describe("rect #bounds", function()
        local bigreal = 9999999.0
        local min,max = math.min, math.max
        local pointinrect = rect.pointinside
        local rectempty = rect.isempty
        local recteq = rect.eq
        local rectexpand = rect.expand
        local rectinside = rect.rectinside
        local rectintersection = rect.intersection
        local rectunion = rect.union

        it("is empty if its dimensions are negative", function()
            assert.is_true(rectempty(0,0,-1,-1))
            assert.is_true(rectempty(bigreal,bigreal,-bigreal,-bigreal))
            assert.is_true(rectempty(-bigreal,-bigreal,-bigreal,-bigreal))
            assert.is_true(rectempty(0,0,bigreal,-1))
            assert.is_true(rectempty(0,0,0,-1))
            assert.is_true(rectempty(0,0,-1,bigreal))
            assert.is_true(rectempty(0,0,-1,0))

            assert.is_false(rectempty(0,0,0,0))
            assert.is_false(rectempty(0,0,-0,0))
            assert.is_false(rectempty(bigreal,bigreal,bigreal,bigreal))
        end)
        it("doesn't contain anything if empty", function()
            local x,y,w,h = 0,0,-1,-1

            assert.is_false(rectinside(0,0,0,0, x,y,w,h))
            assert.is_false(rectinside(x,y,w,h, x,y,w,h))
            assert.is_false(rectinside(0,0,bigreal,bigreal, x,y,w,h))
            assert.is_false(rectinside(0,0,-bigreal,-bigreal, x,y,w,h))
        end)
        it("always contains empty rect if non-empty", function()
            assert.is_true(rectinside(0,0,-1,-1, 0,0,0,0))
            assert.is_true(rectinside(bigreal,bigreal,-bigreal,-bigreal, 0,0,0,0))
            assert.is_true(rectinside(bigreal,bigreal,bigreal,-bigreal, 0,0,0,0))
            assert.is_true(rectinside(bigreal,bigreal,-bigreal,bigreal, 0,0,0,0))
            assert.is_true(rectinside(bigreal,bigreal,-1.0e-5,bigreal, 0,0,0,0))
        end)
        it("may contain a single point", function()
            for i,pt in ipairs({{0,0}, {bigreal,bigreal}, {-bigreal,-bigreal}}) do
                local px,py = pt[1], pt[2]
                local x,y,w,h = 0,0,-1,-1

                x,y,w,h = rectexpand(x,y,w,h, px,py)
                assert.is_false(rectempty(x,y,w,h))
                assert.is_true(pointinrect(px,py, x,y,w,h))
                assert.is_true(recteq(x,y,w,h, px,py,0,0))
            end
        end)
        it("may expand arbitrarily to contain more points", function()
            local points = {}

            local xmin,ymin =  math.huge, math.huge
            local xmax,ymax = -math.huge,-math.huge
            for i = 1,16535 do
                local x = (math.random() - 0.5) * 50
                local y = (math.random() - 0.5) * 50

                points[#points+1] = { x, y }
                xmin = min(xmin, x)
                ymin = min(ymin, y)
                xmax = max(xmax, x)
                ymax = max(ymax, y)
            end

            local x,y,w,h = 0,0,-1,-1
            for i,pt in ipairs(points) do
                local px,py = pt[1], pt[2]
                x,y,w,h = rectexpand(x,y,w,h, px,py)

                assert.is_true(pointinrect(px,py, x,y,w,h))
            end

            local ex,ey,ew,eh = xmin,ymin, xmax-xmin,ymax-ymin
            assert.is_false(rectempty(x,y,w,h))
            assert.is_true(recteq(x,y,w,h, ex,ey,ew,eh, 0.1))
        end)
        it("may expand arbitrarily to contain more rects", function()
            pending("to be tested...")
        end)
        it("may be used to enclose arbitrary geometry", function()
            pending("to be tested...")
        end)
        it("may be tested against other rects", function()
            pending("to be tested...")
        end)
        it("may be intersected with other rects", function()
            pending("to be tested...")
        end)
    end)
end)
