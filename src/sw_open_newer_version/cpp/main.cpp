#include <SketchUpAPI/common.h>
#include <SketchUpAPI/initialize.h>
#include <SketchUpAPI/model/model.h>
#include <unordered_map>
#include <string> // std::string, std::stoi


//#include <windows.h>
#include <shobjidl.h> 
#include <stdio.h> 
#include <iostream>
#include <comdef.h>
using namespace std;

// - Source path
// - Target path
// - SketchUp version (without leading 20)

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PWSTR pCmdLine, int nCmdShow)
{
    int argc;
    LPTSTR* argv = CommandLineToArgvW(pCmdLine, &argc);

    //MessageBoxW(0, pCmdLine, TEXT("lpCmdLine"), MB_OK);
    //for (int i = 0; i < argc; ++i) {
      //  MessageBoxW(0, argv[i], TEXT("argv"), MB_OK);
    //}

    if (argc != 3) {
        cerr << "Wrong number of commandline arguments\n";
        return 1;
    }

    //  Convert strings to ASCII
    const  wchar_t* src = argv[0];
    _bstr_t b0(src);
    const char* source = b0;

    const  wchar_t* tgt = argv[1];
    _bstr_t b1(tgt);
    const char* target = b1;

    int version_name = std::stoi(argv[2]);

    // With version 2021 SketchUp changed to a "versionless" file format, meaning later application versions uses the same file version.
    if (version_name > 21)
        version_name = 21;

    // REVIEW: Must be a way to simply append number to "SUModelVersion_SU" string
    // and get enum from its string name.
    const std::unordered_map<int, SUModelVersion> versions = {
      {3,SUModelVersion_SU3},
      {4,SUModelVersion_SU4},
      {5,SUModelVersion_SU5},
      {6,SUModelVersion_SU6},
      {7,SUModelVersion_SU7},
      {8,SUModelVersion_SU8},
      {13,SUModelVersion_SU2013},
      {14,SUModelVersion_SU2014},
      {15,SUModelVersion_SU2015},
      {16,SUModelVersion_SU2016},
      {17,SUModelVersion_SU2017},
      {18,SUModelVersion_SU2018},
      {19,SUModelVersion_SU2019},
      {20,SUModelVersion_SU2020},
      {21,SUModelVersion_SU2021}
      // 2021 is the first "versionless" file version, also used by later SU versions.
    };
    enum SUModelVersion version = versions.at(version_name);

    SUInitialize();

    SUModelRef model = SU_INVALID;
    SUModelLoadStatus status;
    SUResult res = SUModelCreateFromFileWithStatus(&model, source, &status);
    if (res != SU_ERROR_NONE) {
        cerr << "SUModelCreateFromFileWithStatus Failed with Status = ";
        cerr << status << "\n";
        cerr << "Source " << source << "\n";
        cerr << "Target " << target << "\n";
        cerr << "Target Version " << version_name << "\n";
        SUTerminate();
        return 1;
    }

  SUModelSaveToFileWithVersion(model, target, version);
  SUModelRelease(&model);
  SUTerminate();
  cerr << "Conversion Successful\n";
  return 0;
}
