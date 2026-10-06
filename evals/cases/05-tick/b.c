/* Target: 32-bit Cortex-M0+. SysTick fires every 1 ms. */
#include <stdint.h>
#include <stdbool.h>
#include "cmsis_compiler.h" /* __get_PRIMASK, __disable_irq, __set_PRIMASK */

static volatile uint64_t g_uptime_ms;

void SysTick_Handler(void) { g_uptime_ms++; }

uint64_t uptime_ms(void) {
    uint32_t primask = __get_PRIMASK();
    __disable_irq();
    uint64_t now = g_uptime_ms;
    __set_PRIMASK(primask);
    return now;
}

bool elapsed(uint64_t start_ms, uint64_t timeout_ms) {
    return (uptime_ms() - start_ms) >= timeout_ms;
}
