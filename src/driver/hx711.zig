const gpio = @import("microzig").hal.gpio;

pub fn HX711(comptime pd_sck: type, comptime dout: type) type {
    return struct {
        pub fn init() void {
            gpio.setOutput(pd_sck);
            gpio.setInput(dout);
            gpio.write(pd_sck, .low);
        }

        pub fn read() i24 {
            while (gpio.read(dout) == .high) {}
            var result: u24 = 0;
            for (0..24) |_| {
                gpio.write(pd_sck, .high);
                result <<= 1;
                gpio.write(pd_sck, .low);
                if (gpio.read(dout) == .high) {
                    result |= 1;
                }
            }
            gpio.write(pd_sck, .high);
            gpio.write(pd_sck, .low);
            return @bitCast(i24, result);
        }
    };
}
