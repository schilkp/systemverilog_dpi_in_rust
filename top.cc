#include "Vtop.h"
#include "verilated.h"
#include "verilated_fst_c.h"
#include <iostream>
#include <ostream>

int main(int argc, char **argv, char **) {
  // Setup context, defaults, and parse command line
  Verilated::debug(0);
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  contextp->commandArgs(argc, argv);
  contextp->assertOn(true);
  contextp->traceEverOn(true);

  // Construct the Verilated model, from Vtop.h generated from Verilating
  const std::unique_ptr<Vtop> topp{new Vtop{contextp.get(), ""}};

  VerilatedFstC *tfp = new VerilatedFstC;
  topp->trace(tfp, 99); // Trace 99 levels of hierarchy
  tfp->open(DUMPFILE);

  std::cout << "INF [sim]: Resetting.." << std::endl;

  topp->rst_ni = 0;
  topp->clk_i = 0;
  topp->eval();
  tfp->dump(contextp->time());
  contextp->timeInc(10);
  topp->eval();

  // RESET
  for (size_t i = 0; i < 15; i++) {
    topp->clk_i = 1;
    topp->eval();
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    topp->clk_i = 0;
    topp->eval();
    tfp->dump(contextp->time());
    contextp->timeInc(1);
  }

  std::cout << "INF [sim]: Releasing reset.." << std::endl;
  topp->rst_ni = 1;

  // Simulate until $finish
  for (size_t i = 0; i < 100; i++) {
    if (contextp->gotFinish()) {
      VL_DEBUG_IF(VL_PRINTF("+ Hit $finish\n"););
      break;
    }
    topp->clk_i = 1;
    topp->eval();
    tfp->dump(contextp->time());
    contextp->timeInc(1);
    topp->clk_i = 0;
    topp->eval();
    tfp->dump(contextp->time());
    contextp->timeInc(1);
  }

  // Execute 'final' processes
  topp->final();

  tfp->close();

  // Print statistical summary report
  contextp->statsPrintSummary();

  return 0;
}
