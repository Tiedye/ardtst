const std = @import("std");

fn tokenizer(comptime schema: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var tokenTypeSchemas = std.ArrayList(struct {
        name: []const u8,
        regex: []const u8,
    }).init(allocator);
    var lineIter = std.mem.split(u8, schema, "\n");
    while (lineIter.next()) |line| {
        const separatorIndex = std.mem.indexOf(u8, line, " ") orelse return error.MalformedSchema;
        try tokenTypeSchemas.append(.{
            .name = line[0..separatorIndex],
            .regex = line[(separatorIndex + 1)..],
        });
    }
    for (tokenTypeSchemas.items) |tokenTypeSchema| {
        std.debug.print("{s} {s}\n", .{ tokenTypeSchema.name, tokenTypeSchema.regex });
    }
}

test "tokenizer" {
    try tokenizer(
        \\identifier [a-zA-Z_][a-zA-Z0-9_]*
        \\number [0-9]+
        \\string "[^"]*"
    );
}
