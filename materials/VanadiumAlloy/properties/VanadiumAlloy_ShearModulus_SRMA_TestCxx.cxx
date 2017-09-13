/*!
 * \file   VanadiumAlloy_ShearModulus_SRMA-TestCxx.cxx
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

#include"VanadiumAlloy_ShearModulus_SRMA-cxx.hxx"

struct VanadiumAlloy_ShearModulus_SRMA final
  : public tfel::tests::TestCase
{
  //! constructor
  VanadiumAlloy_ShearModulus_SRMA()
    : tfel::tests::TestCase("MFM/VanadiumAlloy",
			    "ShearModulus_SRMA")
  {} // end of VanadiumAlloy_ShearModulus_SRMA
  //! test execution
  virtual tfel::tests::TestResult
  execute(void) override
  {
    const auto eps = 100e9*std::numeric_limits<double>::epsilon();
    const auto mu  = mfront::VanadiumAlloy_ShearModulus_SRMA{};
    for(const auto T : {300.,400.,500.,600.,700.,800.}){
      const auto y = 127.8e9*(1-7.825e-5*(T-293.15));
      const auto n =  0.3272*(1-3.056e-5*(T-293.15));
      const auto v = y/(2*(n+1));
      TFEL_TESTS_ASSERT(std::abs(mu(T)-v)<eps);
    }
    return this->result;
  } // end of execute
  // destructor
  virtual ~VanadiumAlloy_ShearModulus_SRMA() = default;
};

TFEL_TESTS_GENERATE_PROXY(VanadiumAlloy_ShearModulus_SRMA,
			  "VanadiumAlloy_ShearModulus_SRMA");

int main(void)
{
  using namespace std;
  using namespace tfel::tests;
  auto& manager = TestManager::getTestManager();
  manager.addTestOutput(cout);
  manager.addXMLTestOutput("VanadiumAlloy_ShearModulus_SRMA-cxx.xml");
  TestResult r = manager.execute();
  if(!r.success()){
    return EXIT_FAILURE;
  }
  return EXIT_SUCCESS;
}
