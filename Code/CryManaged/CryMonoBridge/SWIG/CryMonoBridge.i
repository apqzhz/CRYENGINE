%include "CryEngine.swig"

%import "CryCommon.i"
%import "CryEntitySystem.i"

%{
#include <CryMono/IMonoRuntime.h>
%}
%feature("director") IMonoListener;
%feature("director") ICryEngineBasePlugin;
%include "../../../../CryEngine/CryCommon/CryMono/IMonoRuntime.h"