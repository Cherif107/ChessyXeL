local Class = require "ChessyXeL.Class"
local Method = require "ChessyXeL.Method"
local Vector = require "ChessyXeL.geom.Vector"
local FieldStatus = require "ChessyXeL.FieldStatus"

---@class geom.Matrix3 : Class
local Matrix3 = Class "Matrix3"

Matrix3.a = FieldStatus.PUBLIC(nil, nil, 1)
Matrix3.b = FieldStatus.PUBLIC(nil, nil, 0)
Matrix3.c = FieldStatus.PUBLIC(nil, nil, 0)
Matrix3.d = FieldStatus.PUBLIC(nil, nil, 1)
Matrix3.tx = FieldStatus.PUBLIC(nil, nil, 0)
Matrix3.ty = FieldStatus.PUBLIC(nil, nil, 0)

Matrix3.clone =
    Method.PUBLIC(
    function(matrix)
        return Matrix3.new(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty)
    end
)
Matrix3.concat =
    Method.PUBLIC(
    function(matrix, m3)
        local a1 = matrix.a * m3.a + matrix.b * m3.c
        matrix.b = matrix.a * m3.b + matrix.b * m3.d
        matrix.a = a1

        local c1 = matrix.c * m3.a + matrix.d * m3.c
        matrix.d = matrix.c * m3.b + matrix.d * m3.d
        matrix.c = c1

        local tx1 = matrix.tx * m3.a + matrix.ty * m3.c + m3.tx
        matrix.ty = matrix.tx * m3.b + matrix.ty * m3.d + m3.ty
        matrix.tx = tx1
    end
)

Matrix3.copyColumnFrom =
    Method.PUBLIC(
    function(matrix, col, vector4)
        if col > 2 then
            error("Column " .. col .. " out of bounds (2)")
        elseif col == 0 then
            matrix.a, matrix.b = vector4.x, vector4.y
        elseif col == 1 then
            matrix.c, matrix.d = vector4.x, vector4.y
        else
            matrix.tx, matrix.ty = vector4.x, vector4.y
        end
    end
)

Matrix3.copyColumnTo =
    Method.PUBLIC(
    function(matrix, col, vector4)
        if col > 2 then
            error("Column " .. col .. " out of bounds (2)")
        elseif col == 0 then
            vector4.x, vector4.y, vector4.z = matrix.a, matrix.b, 0
        elseif col == 1 then
            vector4.x, vector4.y, vector4.z = matrix.c, matrix.d, 0
        else
            vector4.x, vector4.y, vector4.z = matrix.tx, matrix.ty, 1
        end
    end
)

Matrix3.copyRowFrom =
    Method.PUBLIC(
    function(matrix, row, vector4)
        if row > 2 then
            error("Row " .. row .. " out of bounds (2)")
        elseif row == 0 then
            matrix.a, matrix.c, matrix.tx = vector4.x, vector4.y, vector4.z
        elseif row == 1 then
            matrix.b, matrix.d, matrix.ty = vector4.x, vector4.y, vector4.z
        end
    end
)

Matrix3.copyRowTo =
    Method.PUBLIC(
    function(matrix, row, vector4)
        if row > 2 then
            error("Row " .. row .. " out of bounds (2)")
        elseif row == 0 then
            vector4.x, vector4.y, vector4.z = matrix.a, matrix.c, matrix.tx
        elseif row == 1 then
            vector4.x, vector4.y, vector4.z = matrix.b, matrix.d, matrix.ty
        else
            vector4.setTo(0, 0, 1)
        end
    end
)

Matrix3.createBox =
    Method.PUBLIC(
    function(matrix, scaleX, scaleY, rotation, TX, TY)
        rotation, TX, TY = rotation or 0, TX or 0, TY or 0
        if rotation ~= 0 then
            local cr, sr = math.cos(rotation), math.sin(rotation)
            matrix.a, matrix.b = cr * scaleX, sr * scaleY
            matrix.c, matrix.d = -sr * scaleX, cr * scaleY
        else
            matrix.a, matrix.b = scaleX, 0
            matrix.c, matrix.d = 0, scaleY
        end
        matrix.tx, matrix.ty = TX, TY
    end
)

Matrix3.createGradientBox =
    Method.PUBLIC(
    function(matrix, width, height, rotation, TX, TY)
        rotation, TX, TY = rotation or 0, TX or 0, TY or 0
        matrix.a = width / 1638.4
        matrix.d = height / 1638.4
        if rotation ~= 0 then
            local cr, sr = math.cos(rotation), math.sin(rotation)
            matrix.b, matrix.c = sr * matrix.d, -sr * matrix.a
            matrix.a, matrix.d = matrix.a * cr, matrix.d * cr
        else
            matrix.b, matrix.c = 0, 0
        end
        matrix.tx, matrix.ty = matrix.tx + width / 2, matrix.ty + height / 2
    end
)

Matrix3.equals =
    Method.PUBLIC(
    function(matrix, matrix3)
        return (matrix3 ~= nil and matrix.tx == matrix3.tx and matrix.ty == matrix3.ty and matrix.a == matrix3.a and
            matrix.b == matrix3.b and
            matrix.c == matrix3.c and
            matrix.d == matrix3.d)
    end
)

Matrix3.copyFrom =
    Method.PUBLIC(
    function(matrix, m3)
        matrix.a, matrix.b = m3.a, m3.b
        matrix.c, matrix.d = m3.c, m3.d
        matrix.tx, matrix.ty = m3.tx, m3.ty
    end
)

Matrix3.deltaTransformVector =
    Method.PUBLIC(
    function(matrix, v2, res)
        res = res or Vector()
        res.x = v2.x * matrix.a + v2.y * matrix.c
        res.y = v2.x * matrix.b + v2.y * matrix.d
        return res
    end
)

Matrix3.identity =
    Method.PUBLIC(
    function(matrix)
        matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty = 1, 0, 0, 1, 0, 0
    end
)

Matrix3.invert =
    Method.PUBLIC(
    function(matrix)
        local norm = matrix.a * matrix.d - matrix.b * matrix.c
        if norm == 0 then
            matrix.a, matrix.b, matrix.c, matrix.d = 0, 0, 0, 0
            matrix.tx, matrix.ty = -matrix.tx, -matrix.ty
        else
            norm = 1 / norm
            local a1 = matrix.d * norm
            matrix.d = matrix.a * norm
            matrix.a = a1
            matrix.b = matrix.b * -norm
            matrix.d = matrix.d * -norm

            local tx1 = -matrix.a * matrix.tx - matrix.c * matrix.ty
            matrix.ty = -matrix.b * matrix.tx - matrix.d * matrix.ty
            matrix.tx = tx1
        end
        return matrix
    end
)

Matrix3.rotate =
    Method.PUBLIC(
    function(matrix, theta)
        local ct, st = math.cos(theta), math.sin(theta)

        local a1 = matrix.a * ct - matrix.b * st
        matrix.b = matrix.a * st + matrix.b * ct
        matrix.a = a1

        local c1 = matrix.c * ct - matrix.d * st
        matrix.d = matrix.c * st + matrix.d * ct
        matrix.c = c1

        local tx1 = matrix.tx * ct - matrix.ty * st
        matrix.b = matrix.tx * st + matrix.ty * ct
        matrix.tx = tx1
    end
)

Matrix3.scale =
    Method.PUBLIC(
    function(matrix, sx, sy)
        matrix.a, matrix.b = matrix.a * sx, matrix.b * sy
        matrix.c, matrix.d = matrix.c * sx, matrix.d * sy
        matrix.tx, matrix.ty = matrix.tx * sx, matrix.ty * sy
    end
)

Matrix3.setRotation =
    Method.PUBLIC(
    function(matrix, theta, scale)
        scale = scale or 1
        matrix.a = math.cos(theta) * scale
        matrix.b = math.sin(theta) * scale
        matrix.c, matrix.d = -matrix.c, matrix.a
    end
)

Matrix3.setTo =
    Method.PUBLIC(
    function(matrix, a, b, c, d, tx, ty)
        matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty = a or 1, b or 0, c or 0, d or 1, tx or 0, ty or 0
    end
)

Matrix3.transformVector =
    Method.PUBLIC(
    function(matrix, pos, res)
        res = res or Vector()
        res.x = pos.x * matrix.a + pos.y * matrix.c + matrix.tx
        res.y = pos.y * matrix.b + pos.y * matrix.d + matrix.ty
        return res
    end
)

Matrix3.translate =
    Method.PUBLIC(
    function(matrix, dx, dy)
        matrix.tx = matrix.tx + dx
        matrix.ty = matrix.ty + dy
    end
)

Matrix3.new = function (a, b, c, d, tx, ty)
    local matrix = Matrix3.create()
    matrix.setTo(a, b, c, d, tx, ty)
    return matrix
end

return Matrix3