/*!
 * \file   VanadiumAlloy_YoungModulus_SRMA-TestCxx.cxx
 * \brief    
 * \author THOMAS HELFER
 * \date   20 juil. 2015
 */

#ifdef NDEBUG
#undef NDEBUG
#endif

#include<cmath>
#include<limits>
#include<cstdlib>
#include<iostream>

#include"TFEL/Tests/TestCase.hxx"
#include"TFEL/Tests/TestProxy.hxx"
#include"TFEL/Tests/TestManager.hxx"

#include"VanadiumAlloy_YoungModulus_SRMA-cxx.hxx"

struct VanadiumAlloy_YoungModulus_SRMA final
  : public tfel::tests::TestCase
{
  //! \brief constructor
  VanadiumAlloy_YoungModulus_SRMA()
    : tfel::tests::TestCase("MFM/VanadiumAlloy",
			    "YoungModulus_SRMA")
  {} // end of VanadiumAlloy_YoungModulus_SRMA
  //! test execution
  tfel::tests::TestResult execute() override  {
    const auto eps = 100e9*std::numeric_limits<double>::epsilon();
    const auto y   = mfront::VanadiumAlloy_YoungModulus_SRMA{};
    for(const auto T : {300.,400.,500.,600.,700.,800.}){
      const auto v = 127.8e9*(1-7.825e-5*(T-293.15));
      TFEL_TESTS_ASSERT(std::abs(y(T)-v)<eps);
    }
    return this->result;
  } // end of execute
  // \brief destructor
  ~VanadiumAlloy_YoungModulus_SRMA() override = default;
};

TFEL_TESTS_GENERATE_PROXY(VanadiumAlloy_YoungModulus_SRMA,
			  "VanadiumAlloy_YoungModulus_SRMA");

int main(void)
{
  using namespace std;
  using namespace tfel::tests;
  auto& manager = TestManager::getTestManager();
  manager.addTestOutput(cout);
  manager.addXMLTestOutput("VanadiumAlloy_YoungModulus_SRMA-cxx.xml");
  TestResult r = manager.execute();
  if(!r.success()){
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
