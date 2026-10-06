/* Target: 32-bit Cortex-M0+. SysTick fires every 1 ms. */
#include <stdint.h>
#include <stdbool.h>

static volatile uint64_t g_uptime_ms;

void SysTick_Handler(void) { g_uptime_ms++; }

uint64_t uptime_ms(void) { return g_uptime_ms; }

bool elapsed(uint64_t start_ms, uint64_t timeout_ms) {
    return (uptime_ms() - start_ms) >= timeout_ms;
}
