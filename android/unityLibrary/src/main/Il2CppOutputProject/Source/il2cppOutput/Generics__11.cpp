#include "pch-cpp.hpp"





struct VirtualActionInvoker0
{
	typedef void (*Action)(void*, const RuntimeMethod*);

	static inline void Invoke (Il2CppMethodSlot slot, RuntimeObject* obj)
	{
		const VirtualInvokeData& invokeData = il2cpp_codegen_get_virtual_invoke_data(slot, obj);
		((Action)invokeData.methodPtr)(obj, invokeData.method);
	}
};
struct InterfaceActionInvoker0
{
	typedef void (*Action)(void*, const RuntimeMethod*);

	static inline void Invoke (Il2CppMethodSlot slot, RuntimeClass* declaringInterface, RuntimeObject* obj)
	{
		const VirtualInvokeData& invokeData = il2cpp_codegen_get_interface_invoke_data(slot, obj, declaringInterface);
		((Action)invokeData.methodPtr)(obj, invokeData.method);
	}
};
template <typename T1>
struct InterfaceActionInvoker1Invoker;
template <typename T1>
struct InterfaceActionInvoker1Invoker<T1*>
{
	static inline void Invoke (Il2CppMethodSlot slot, RuntimeClass* declaringInterface, RuntimeObject* obj, T1* p1)
	{
		const VirtualInvokeData& invokeData = il2cpp_codegen_get_interface_invoke_data(slot, obj, declaringInterface);
		void* params[1] = { p1 };
		invokeData.method->invoker_method(il2cpp_codegen_get_method_pointer(invokeData.method), invokeData.method, obj, params, params[0]);
	}
};
template <typename R>
struct InterfaceFuncInvoker0
{
	typedef R (*Func)(void*, const RuntimeMethod*);

	static inline R Invoke (Il2CppMethodSlot slot, RuntimeClass* declaringInterface, RuntimeObject* obj)
	{
		const VirtualInvokeData& invokeData = il2cpp_codegen_get_interface_invoke_data(slot, obj, declaringInterface);
		return ((Func)invokeData.methodPtr)(obj, invokeData.method);
	}
};
template <typename R, typename T1>
struct InterfaceFuncInvoker1
{
	typedef R (*Func)(void*, T1, const RuntimeMethod*);

	static inline R Invoke (Il2CppMethodSlot slot, RuntimeClass* declaringInterface, RuntimeObject* obj, T1 p1)
	{
		const VirtualInvokeData& invokeData = il2cpp_codegen_get_interface_invoke_data(slot, obj, declaringInterface);
		return ((Func)invokeData.methodPtr)(obj, p1, invokeData.method);
	}
};
template <typename T1>
struct InvokerActionInvoker1;
template <typename T1>
struct InvokerActionInvoker1<T1*>
{
	static inline void Invoke (Il2CppMethodPointer methodPtr, const RuntimeMethod* method, void* obj, T1* p1)
	{
		void* params[1] = { p1 };
		method->invoker_method(methodPtr, method, obj, params, params[0]);
	}
};
template <typename T1, typename T2>
struct InvokerActionInvoker2;
template <typename T1, typename T2>
struct InvokerActionInvoker2<T1*, T2*>
{
	static inline void Invoke (Il2CppMethodPointer methodPtr, const RuntimeMethod* method, void* obj, T1* p1, T2* p2)
	{
		void* params[2] = { p1, p2 };
		method->invoker_method(methodPtr, method, obj, params, params[1]);
	}
};
template <typename T1, typename T2, typename T3>
struct InvokerActionInvoker3;
template <typename T1, typename T2, typename T3>
struct InvokerActionInvoker3<T1*, T2*, T3*>
{
	static inline void Invoke (Il2CppMethodPointer methodPtr, const RuntimeMethod* method, void* obj, T1* p1, T2* p2, T3* p3)
	{
		void* params[3] = { p1, p2, p3 };
		method->invoker_method(methodPtr, method, obj, params, params[2]);
	}
};

struct Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87;
struct Action_1_tEB0353AA1A112B6F2D921B58DCC9D9D4C0498E6E;
struct Dictionary_2_t403063CE4960B4F46C688912237C6A27E550FF55;
struct ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD;
struct Func_1_tD59A12717D79BFB403BF973694B1BE5B85474BD1;
struct Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B;
struct Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0;
struct Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9;
struct IEnumerable_1_t29E7244AE33B71FA0981E50D5BC73B7938F35C66;
struct IEnumerator_1_t75CB2681E18F7F2791528FA2CA60361FDB5DA08D;
struct IObservable_1_tA29A83F0C2D67B7465AEA27D123F8F8B6514E475;
struct IObserver_1_t094BE2515872266E98A772AEA02B413105F16A8B;
struct IXRInputValueReader_1_tC86C12DB1216B425E7880781CAFFE046A4E03898;
struct InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB;
struct Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0;
struct List_1_t90832B88D7207769654164CC28440CF594CC397D;
struct List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A;
struct Predicate_1_t8342C85FF4E41CD1F7024AC0CDC3E5312A32CB12;
struct Predicate_1_t7F48518B008C1472339EEEBABA3DE203FE1F26ED;
struct Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93;
struct TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7;
struct TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970;
struct TaskFactory_1_t38FA2E08CB3E397D4EAEB78FF83BFC2FF0087800;
struct TaskFactory_1_tF4CDC5BDA20AE9BD3F65B6146CDCD3F753003E1D;
struct Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC;
struct Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9;
struct UnityObjectReferenceCache_1_t5037B37A78F59591F798651810A820937FB97158;
struct UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D;
struct UnityObjectReferenceCache_2_tDDA23E8D68929712BE24F100B89ED0291001D0DB;
struct WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F;
struct Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C;
struct WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6;
struct WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B;
struct WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0;
struct WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816;
struct WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174;
struct WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C;
struct WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336;
struct WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7;
struct XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D;
struct XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0;
struct XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1;
struct XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F;
struct Action_1U5BU5D_tB846E6FE2326CCD34124D1E5D70117C9D33DEE76;
struct EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4;
struct ByteU5BU5D_tA6237BF417AE52AD70CFB4EF24A7A82613DF9031;
struct CharU5BU5D_t799905CF001DD5F13F7DBB310181FC4D8B7D0AAB;
struct DelegateU5BU5D_tC5AB7E8F745616680F337909D3A8E6C722CDF771;
struct InputBindingU5BU5D_t7E47E87B9CAE12B6F6A0659008B425C58D84BB57;
struct Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C;
struct IntPtrU5BU5D_tFD177F8C806A6921AD7150264CCC62FA00CAD832;
struct StackTraceU5BU5D_t32FBCB20930EAF5BAE3F450FF75228E5450DA0DF;
struct TypeU5BU5D_t97234E1129B564EB38B8D85CAC2AD8B5B9522FFB;
struct __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC;
struct Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07;
struct Binder_t91BFCE95A7057FADF4D8A1A342AFE52872246235;
struct CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B;
struct ContextCallback_tE8AFBDBFCC040FDA8DA8C1EEFE9BD66B16BDA007;
struct Delegate_t;
struct DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E;
struct Exception_t;
struct ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757;
struct IAsyncStateMachine_t0680C7F905C553076B552D5A1A6E39E2F0F36AA2;
struct IDictionary_t6D03155AF1FA9083817AA5B6AD7DEEACC26AB220;
struct IDisposable_t030E0496B4E0E4E4F086825007979AF51F7248C5;
struct InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD;
struct InputActionAsset_tF217AC5223B4AAA46EBCB44B33E9259FB117417D;
struct InputActionMap_tFCE82E0E014319D4DED9F8962B06655DD0420A09;
struct InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1;
struct MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553;
struct MethodInfo_t;
struct Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C;
struct OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662;
struct OverflowException_t6F6AD8CACE20C37F701C05B373A215C4802FAB0C;
struct SafeSerializationManager_tCBB85B95DFD1634237140CD892E82D06ECB3F5E6;
struct StackGuard_tACE063A1B7374BDF4AD472DE4585D05AD8745352;
struct String_t;
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572;
struct TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0;
struct TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E;
struct Type_t;
struct Void_t4861ACF8F4594C3437BB48B6E56783494B843915;
struct XRInputDeviceValueReader_t91D732DACFC1260DE12B5C0EA0CE33B0EAF2581A;
struct XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59;
struct ContingentProperties_t3FA59480914505CEA917B1002EC675F29D0CB540;

IL2CPP_EXTERN_C RuntimeClass* Debug_t8394C7EEAECA3689C2C9B9DE9C7166D73596276F_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* IDisposable_t030E0496B4E0E4E4F086825007979AF51F7248C5_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* IEnumerator_t7B609C2FFA6EB5167D9C62A0C32A21DE2F666DAA_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* Math_tEB65DE7CA8B083C412C969C92981C030865486CE_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* OverflowException_t6F6AD8CACE20C37F701C05B373A215C4802FAB0C_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C RuntimeClass* Sorting_tBB4ACAADCAA21EA710DD3998A0614ABDEF8FD8A6_il2cpp_TypeInfo_var;
IL2CPP_EXTERN_C const RuntimeMethod* InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989_RuntimeMethod_var;
IL2CPP_EXTERN_C const RuntimeMethod* InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7_RuntimeMethod_var;
struct Delegate_t_marshaled_com;
struct Delegate_t_marshaled_pinvoke;
struct Exception_t_marshaled_com;
struct Exception_t_marshaled_pinvoke;

struct EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4;
struct DelegateU5BU5D_tC5AB7E8F745616680F337909D3A8E6C722CDF771;
struct Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C;
struct __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC;

IL2CPP_EXTERN_C_BEGIN
IL2CPP_EXTERN_C_END

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
struct InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB  : public RuntimeObject
{
	String_t* ___m_Name;
};
struct Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0 : public RuntimeObject {};
struct List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A  : public RuntimeObject
{
	__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ____items;
	int32_t ____size;
	int32_t ____version;
	RuntimeObject* ____syncRoot;
};
struct TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7  : public RuntimeObject
{
	Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* ____task;
};
struct TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970  : public RuntimeObject
{
	Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* ____task;
};
struct UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D  : public RuntimeObject
{
	Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C* ___m_CapturedObject;
	RuntimeObject* ___m_Interface;
};
struct WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F  : public RuntimeObject
{
	TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* ___completion;
	Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* ___currentResult;
};
struct Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C  : public RuntimeObject
{
	WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* ___m_Observable;
	RuntimeObject* ___m_Observer;
};
struct WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816  : public RuntimeObject
{
	RuntimeObject* ___m_Source;
	Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___m_Predicate;
};
struct XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D  : public RuntimeObject
{
	Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* ____buckets;
	EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* ____entries;
	int32_t ____numEntries;
	ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* ____extractKey;
};
struct XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0  : public RuntimeObject
{
	XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* ____state;
};
struct ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757  : public RuntimeObject
{
	Exception_t* ___m_Exception;
	RuntimeObject* ___m_stackTrace;
};
struct MemberInfo_t  : public RuntimeObject
{
};
struct String_t  : public RuntimeObject
{
	int32_t ____stringLength;
	Il2CppChar ____firstChar;
};
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572  : public RuntimeObject
{
	int32_t ___m_taskId;
	Delegate_t* ___m_action;
	RuntimeObject* ___m_stateObject;
	TaskScheduler_t3F0550EBEF7C41F74EC8C08FF4BED0D8CE66006E* ___m_taskScheduler;
	Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* ___m_parent;
	int32_t ___m_stateFlags;
	RuntimeObject* ___m_continuationObject;
	ContingentProperties_t3FA59480914505CEA917B1002EC675F29D0CB540* ___m_contingentProperties;
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F  : public RuntimeObject
{
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F_marshaled_pinvoke
{
};
struct ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F_marshaled_com
{
};
struct BypassScope_t801793A02437762F196198D282A1980396D8B968 
{
	XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* ___m_Reader;
};
struct ConfiguredTaskAwaiter_t1B79F058B7765DEB6DAEE97B8760E819CAED47BA 
{
	Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* ___m_task;
	bool ___m_continueOnCapturedContext;
};
typedef Il2CppFullySharedGenericStruct Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E;
typedef Il2CppFullySharedGenericStruct Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF;
struct InlinedArray_1_tC208D319D19C2B3DF550BD9CDC11549F23D8F91B 
{
	int32_t ___length;
	Action_1_tEB0353AA1A112B6F2D921B58DCC9D9D4C0498E6E* ___firstValue;
	Action_1U5BU5D_tB846E6FE2326CCD34124D1E5D70117C9D33DEE76* ___additionalValues;
};
struct InputFeatureUsage_1_tE336B2F0B9AC721519BFA17A08D6353FD5221637 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct InputFeatureUsage_1_t4EF7DDCAC35EE23BA72694AC2AB76CF4A879FFD9 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct InputFeatureUsage_1_t8489CEC68B1EC178F2634079A9D7CD9E90D3CF5D 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct InputFeatureUsage_1_t311D0F42F1A7BF37D3CEAC15A53A1F24165F1848 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct InputFeatureUsage_1_tD73AC74B29139087A83959CB3395A0580A2128AE 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct InputFeatureUsage_1_tEB160A05BCDCCA4F96072CBA0866498D06B9A27C 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct InputFeatureUsage_1_t2E901FA41650EB29399194768CAA93D477CEBC58 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct InputFeatureUsage_1_t8FA831CB65EB7520D33B55F11443959DE72B2F8C 
{
	String_t* ___U3CnameU3Ek__BackingField;
};
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_pinvoke
{
	char* ___U3CnameU3Ek__BackingField;
};
#endif
#ifndef InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
#define InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com_define
struct InputFeatureUsage_1_t66EDAF8AFFA2E9DDC0248C48B76ADAB8E2728858_marshaled_com
{
	Il2CppChar* ___U3CnameU3Ek__BackingField;
};
#endif
struct Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC  : public Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572
{
	Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* ___m_result;
};
struct Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9 : public Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572 {};
struct WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6 : public RuntimeObject {};
struct WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B : public RuntimeObject {};
struct WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174 : public RuntimeObject {};
struct WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C : public RuntimeObject {};
struct WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809 
{
	__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___m_Data;
	int32_t ___m_Start;
	int32_t ___m_Length;
};
struct AsyncMethodBuilderCore_tD5ABB3A2536319A3345B32A5481E37E23DD8CEDF 
{
	RuntimeObject* ___m_stateMachine;
	Action_tD00B0A84D7945E50C2DFFC28EFEE6ED44ED2AD07* ___m_defaultContextAction;
};
struct AsyncMethodBuilderCore_tD5ABB3A2536319A3345B32A5481E37E23DD8CEDF_marshaled_pinvoke
{
	RuntimeObject* ___m_stateMachine;
	Il2CppMethodPointer ___m_defaultContextAction;
};
struct AsyncMethodBuilderCore_tD5ABB3A2536319A3345B32A5481E37E23DD8CEDF_marshaled_com
{
	RuntimeObject* ___m_stateMachine;
	Il2CppMethodPointer ___m_defaultContextAction;
};
struct Boolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22 
{
	bool ___m_value;
};
struct CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED 
{
	CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B* ____source;
};
struct CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_marshaled_pinvoke
{
	CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B* ____source;
};
struct CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED_marshaled_com
{
	CancellationTokenSource_tAAE1E0033BCFC233801F8CB4CED5C852B350CB7B* ____source;
};
struct Char_t521A6F19B456D956AF452D926C32709DC03D6B17 
{
	Il2CppChar ___m_value;
};
struct Enum_t2A1A94B24E3B776EEF4E5E485E290BB9D4D072E2  : public ValueType_t6D9B272BD21782F0A9A14F2E41F85A50E97A986F
{
};
struct Enum_t2A1A94B24E3B776EEF4E5E485E290BB9D4D072E2_marshaled_pinvoke
{
};
struct Enum_t2A1A94B24E3B776EEF4E5E485E290BB9D4D072E2_marshaled_com
{
};
struct InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD 
{
	uint64_t ___m_DeviceId;
	bool ___m_Initialized;
};
struct InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD_marshaled_pinvoke
{
	uint64_t ___m_DeviceId;
	int32_t ___m_Initialized;
};
struct InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD_marshaled_com
{
	uint64_t ___m_DeviceId;
	int32_t ___m_Initialized;
};
struct Int32_t680FF22E76F6EFAD4375103CBBFFA0421349384C 
{
	int32_t ___m_value;
};
struct IntPtr_t 
{
	void* ___m_value;
};
struct Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974 
{
	float ___x;
	float ___y;
	float ___z;
	float ___w;
};
struct Single_t4530F2FF86FCB0DC29F35385CA1BD21BE294761C 
{
	float ___m_value;
};
struct UInt32_t1833D51FFA667B18A5AA4B8D34DE284F8495D29B 
{
	uint32_t ___m_value;
};
struct Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 
{
	float ___x;
	float ___y;
};
struct Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 
{
	float ___x;
	float ___y;
	float ___z;
};
struct Void_t4861ACF8F4594C3437BB48B6E56783494B843915 
{
	union
	{
		struct
		{
		};
		uint8_t Void_t4861ACF8F4594C3437BB48B6E56783494B843915__padding[1];
	};
};
struct AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4 
{
	AsyncMethodBuilderCore_tD5ABB3A2536319A3345B32A5481E37E23DD8CEDF ___m_coreState;
	Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* ___m_task;
};
struct CallbackArray_1_tDFF8C4C6015023B6C2E70BAD26D8BC6BF00D8775 
{
	bool ___m_CannotMutateCallbacksArray;
	InlinedArray_1_tC208D319D19C2B3DF550BD9CDC11549F23D8F91B ___m_Callbacks;
	InlinedArray_1_tC208D319D19C2B3DF550BD9CDC11549F23D8F91B ___m_CallbacksToAdd;
	InlinedArray_1_tC208D319D19C2B3DF550BD9CDC11549F23D8F91B ___m_CallbacksToRemove;
};
struct Status_tE01E96437CB49CBFF241304B0B5F57A27CDE4B5F 
{
	int32_t ___value__;
};
struct WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0 : public RuntimeObject {};
struct WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336 : public RuntimeObject {};
struct Delegate_t  : public RuntimeObject
{
	intptr_t ___method_ptr;
	intptr_t ___invoke_impl;
	RuntimeObject* ___m_target;
	intptr_t ___method;
	intptr_t ___delegate_trampoline;
	intptr_t ___extra_arg;
	intptr_t ___method_code;
	intptr_t ___interp_method;
	intptr_t ___interp_invoke_impl;
	MethodInfo_t* ___method_info;
	MethodInfo_t* ___original_method_info;
	DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E* ___data;
	bool ___method_is_virtual;
};
struct Delegate_t_marshaled_pinvoke
{
	intptr_t ___method_ptr;
	intptr_t ___invoke_impl;
	Il2CppIUnknown* ___m_target;
	intptr_t ___method;
	intptr_t ___delegate_trampoline;
	intptr_t ___extra_arg;
	intptr_t ___method_code;
	intptr_t ___interp_method;
	intptr_t ___interp_invoke_impl;
	MethodInfo_t* ___method_info;
	MethodInfo_t* ___original_method_info;
	DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E* ___data;
	int32_t ___method_is_virtual;
};
struct Delegate_t_marshaled_com
{
	intptr_t ___method_ptr;
	intptr_t ___invoke_impl;
	Il2CppIUnknown* ___m_target;
	intptr_t ___method;
	intptr_t ___delegate_trampoline;
	intptr_t ___extra_arg;
	intptr_t ___method_code;
	intptr_t ___interp_method;
	intptr_t ___interp_invoke_impl;
	MethodInfo_t* ___method_info;
	MethodInfo_t* ___original_method_info;
	DelegateData_t9B286B493293CD2D23A5B2B5EF0E5B1324C2B77E* ___data;
	int32_t ___method_is_virtual;
};
struct Exception_t  : public RuntimeObject
{
	String_t* ____className;
	String_t* ____message;
	RuntimeObject* ____data;
	Exception_t* ____innerException;
	String_t* ____helpURL;
	RuntimeObject* ____stackTrace;
	String_t* ____stackTraceString;
	String_t* ____remoteStackTraceString;
	int32_t ____remoteStackIndex;
	RuntimeObject* ____dynamicMethods;
	int32_t ____HResult;
	String_t* ____source;
	SafeSerializationManager_tCBB85B95DFD1634237140CD892E82D06ECB3F5E6* ____safeSerializationManager;
	StackTraceU5BU5D_t32FBCB20930EAF5BAE3F450FF75228E5450DA0DF* ___captured_traces;
	IntPtrU5BU5D_tFD177F8C806A6921AD7150264CCC62FA00CAD832* ___native_trace_ips;
	int32_t ___caught_in_unmanaged;
};
struct Exception_t_marshaled_pinvoke
{
	char* ____className;
	char* ____message;
	RuntimeObject* ____data;
	Exception_t_marshaled_pinvoke* ____innerException;
	char* ____helpURL;
	Il2CppIUnknown* ____stackTrace;
	char* ____stackTraceString;
	char* ____remoteStackTraceString;
	int32_t ____remoteStackIndex;
	Il2CppIUnknown* ____dynamicMethods;
	int32_t ____HResult;
	char* ____source;
	SafeSerializationManager_tCBB85B95DFD1634237140CD892E82D06ECB3F5E6* ____safeSerializationManager;
	StackTraceU5BU5D_t32FBCB20930EAF5BAE3F450FF75228E5450DA0DF* ___captured_traces;
	Il2CppSafeArray* ___native_trace_ips;
	int32_t ___caught_in_unmanaged;
};
struct Exception_t_marshaled_com
{
	Il2CppChar* ____className;
	Il2CppChar* ____message;
	RuntimeObject* ____data;
	Exception_t_marshaled_com* ____innerException;
	Il2CppChar* ____helpURL;
	Il2CppIUnknown* ____stackTrace;
	Il2CppChar* ____stackTraceString;
	Il2CppChar* ____remoteStackTraceString;
	int32_t ____remoteStackIndex;
	Il2CppIUnknown* ____dynamicMethods;
	int32_t ____HResult;
	Il2CppChar* ____source;
	SafeSerializationManager_tCBB85B95DFD1634237140CD892E82D06ECB3F5E6* ____safeSerializationManager;
	StackTraceU5BU5D_t32FBCB20930EAF5BAE3F450FF75228E5450DA0DF* ___captured_traces;
	Il2CppSafeArray* ___native_trace_ips;
	int32_t ___caught_in_unmanaged;
};
struct InputActionType_t7E3615BDDF3C84F39712E5889559D3AD8E773108 
{
	int32_t ___value__;
};
struct InputDeviceCharacteristics_t7BD1A06C6AE9FBD26F4FC105269861694217BD82 
{
	uint32_t ___value__;
};
struct InputTrackingState_tCBE220E8A09D62DA1C6BD96F76943FE90F15778D 
{
	uint32_t ___value__;
};
struct Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C  : public RuntimeObject
{
	intptr_t ___m_CachedPtr;
};
struct Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C_marshaled_pinvoke
{
	intptr_t ___m_CachedPtr;
};
struct Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C_marshaled_com
{
	intptr_t ___m_CachedPtr;
};
struct ProfilerMarker_tA256E18DA86EDBC5528CE066FC91C96EE86501AD 
{
	intptr_t ___m_Ptr;
};
struct RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B 
{
	intptr_t ___value;
};
struct TaskCreationOptions_tB15CB42D61B8958640A7C702A79097B56D5C7ABA 
{
	int32_t ___value__;
};
struct ActionFlags_t639BD2944E073F8DD263CE2CA581FC62C401AB1E 
{
	int32_t ___value__;
};
struct Flags_t2ED4EFE461994B03533B3B524C8C2EA71315AAE6 
{
	int32_t ___value__;
};
struct InputSourceMode_tC6F86938AEFC93650B200F13CB1CDF660E091A6C 
{
	int32_t ___value__;
};
struct U3CWaitForCompletionU3Ed__15_t1E7A90912CE0FB4BBFDADC017893E65373B96937 
{
	int32_t ___U3CU3E1__state;
	AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4 ___U3CU3Et__builder;
	WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* ___U3CU3E4__this;
	ConfiguredTaskAwaiter_t1B79F058B7765DEB6DAEE97B8760E819CAED47BA ___U3CU3Eu__1;
};
struct Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93 : public RuntimeObject {};
struct InputBinding_t0D75BD1538CF81D29450D568D5C938E111633EC5 
{
	String_t* ___m_Name;
	String_t* ___m_Id;
	String_t* ___m_Path;
	String_t* ___m_Interactions;
	String_t* ___m_Processors;
	String_t* ___m_Groups;
	String_t* ___m_Action;
	int32_t ___m_Flags;
	String_t* ___m_OverridePath;
	String_t* ___m_OverrideInteractions;
	String_t* ___m_OverrideProcessors;
};
struct InputBinding_t0D75BD1538CF81D29450D568D5C938E111633EC5_marshaled_pinvoke
{
	char* ___m_Name;
	char* ___m_Id;
	char* ___m_Path;
	char* ___m_Interactions;
	char* ___m_Processors;
	char* ___m_Groups;
	char* ___m_Action;
	int32_t ___m_Flags;
	char* ___m_OverridePath;
	char* ___m_OverrideInteractions;
	char* ___m_OverrideProcessors;
};
struct InputBinding_t0D75BD1538CF81D29450D568D5C938E111633EC5_marshaled_com
{
	Il2CppChar* ___m_Name;
	Il2CppChar* ___m_Id;
	Il2CppChar* ___m_Path;
	Il2CppChar* ___m_Interactions;
	Il2CppChar* ___m_Processors;
	Il2CppChar* ___m_Groups;
	Il2CppChar* ___m_Action;
	int32_t ___m_Flags;
	Il2CppChar* ___m_OverridePath;
	Il2CppChar* ___m_OverrideInteractions;
	Il2CppChar* ___m_OverrideProcessors;
};
struct MulticastDelegate_t  : public Delegate_t
{
	DelegateU5BU5D_tC5AB7E8F745616680F337909D3A8E6C722CDF771* ___delegates;
};
struct MulticastDelegate_t_marshaled_pinvoke : public Delegate_t_marshaled_pinvoke
{
	Delegate_t_marshaled_pinvoke** ___delegates;
};
struct MulticastDelegate_t_marshaled_com : public Delegate_t_marshaled_com
{
	Delegate_t_marshaled_com** ___delegates;
};
struct ScriptableObject_tB3BFDB921A1B1795B38A5417D3B97A89A140436A  : public Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C
{
};
struct ScriptableObject_tB3BFDB921A1B1795B38A5417D3B97A89A140436A_marshaled_pinvoke : public Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C_marshaled_pinvoke
{
};
struct ScriptableObject_tB3BFDB921A1B1795B38A5417D3B97A89A140436A_marshaled_com : public Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C_marshaled_com
{
};
struct SystemException_tCC48D868298F4C0705279823E34B00F4FBDB7295  : public Exception_t
{
};
struct Type_t  : public MemberInfo_t
{
	RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B ____impl;
};
struct XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59  : public RuntimeObject
{
	int32_t ___m_InputSourceMode;
	InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___m_InputAction;
	InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1* ___m_InputActionReference;
	UnityObjectReferenceCache_1_t5037B37A78F59591F798651810A820937FB97158* ___m_InputActionReferenceCache;
};
struct ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD  : public MulticastDelegate_t
{
};
struct Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B  : public MulticastDelegate_t
{
};
struct Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0  : public MulticastDelegate_t
{
};
struct Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9  : public MulticastDelegate_t
{
};
struct Nullable_1_t11786EE914FE65E70B9671129B0DFC4D0DE80C44 
{
	bool ___hasValue;
	InputBinding_t0D75BD1538CF81D29450D568D5C938E111633EC5 ___value;
};
struct WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7  : public MulticastDelegate_t
{
};
struct XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F : public XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59 {};
struct ArithmeticException_t07E77822D0007642BC8959A671E70D1F33C84FEA  : public SystemException_tCC48D868298F4C0705279823E34B00F4FBDB7295
{
};
struct InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1  : public ScriptableObject_tB3BFDB921A1B1795B38A5417D3B97A89A140436A
{
	InputActionAsset_tF217AC5223B4AAA46EBCB44B33E9259FB117417D* ___m_Asset;
	String_t* ___m_ActionId;
	InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___m_Action;
};
struct OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662  : public SystemException_tCC48D868298F4C0705279823E34B00F4FBDB7295
{
	CancellationToken_t51142D9C6D7C02D314DA34A6A7988C528992FFED ____cancellationToken;
};
struct XRInputDeviceValueReader_t91D732DACFC1260DE12B5C0EA0CE33B0EAF2581A  : public ScriptableObject_tB3BFDB921A1B1795B38A5417D3B97A89A140436A
{
	uint32_t ___m_Characteristics;
};
struct XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1  : public XRInputDeviceValueReader_t91D732DACFC1260DE12B5C0EA0CE33B0EAF2581A
{
	InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* ___m_Usage;
	InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD ___m_InputDevice;
};
struct InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD  : public RuntimeObject
{
	String_t* ___m_Name;
	int32_t ___m_Type;
	String_t* ___m_ExpectedControlType;
	String_t* ___m_Id;
	String_t* ___m_Processors;
	String_t* ___m_Interactions;
	InputBindingU5BU5D_t7E47E87B9CAE12B6F6A0659008B425C58D84BB57* ___m_SingletonActionBindings;
	int32_t ___m_Flags;
	Nullable_1_t11786EE914FE65E70B9671129B0DFC4D0DE80C44 ___m_BindingMask;
	int32_t ___m_BindingsStartIndex;
	int32_t ___m_BindingsCount;
	int32_t ___m_ControlStartIndex;
	int32_t ___m_ControlCount;
	int32_t ___m_ActionIndexInState;
	InputActionMap_tFCE82E0E014319D4DED9F8962B06655DD0420A09* ___m_ActionMap;
	CallbackArray_1_tDFF8C4C6015023B6C2E70BAD26D8BC6BF00D8775 ___m_OnStarted;
	CallbackArray_1_tDFF8C4C6015023B6C2E70BAD26D8BC6BF00D8775 ___m_OnCanceled;
	CallbackArray_1_tDFF8C4C6015023B6C2E70BAD26D8BC6BF00D8775 ___m_OnPerformed;
};
struct OverflowException_t6F6AD8CACE20C37F701C05B373A215C4802FAB0C  : public ArithmeticException_t07E77822D0007642BC8959A671E70D1F33C84FEA
{
};
struct List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A_StaticFields
{
	__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___s_emptyArray;
};
struct String_t_StaticFields
{
	String_t* ___Empty;
};
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_StaticFields
{
	int32_t ___s_taskIdCounter;
	RuntimeObject* ___s_taskCompletionSentinel;
	bool ___s_asyncDebuggingEnabled;
	Action_1_t6F9EB113EB3F16226AEF811A2744F4111C116C87* ___s_taskCancelCallback;
	Func_1_tD59A12717D79BFB403BF973694B1BE5B85474BD1* ___s_createContingentProperties;
	TaskFactory_tF781BD37BE23917412AD83424D1497C7C1509DF0* ___U3CFactoryU3Ek__BackingField;
	Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* ___U3CCompletedTaskU3Ek__BackingField;
	Predicate_1_t7F48518B008C1472339EEEBABA3DE203FE1F26ED* ___s_IsExceptionObservedByParentPredicate;
	ContextCallback_tE8AFBDBFCC040FDA8DA8C1EEFE9BD66B16BDA007* ___s_ecCallback;
	Predicate_1_t8342C85FF4E41CD1F7024AC0CDC3E5312A32CB12* ___s_IsTaskContinuationNullPredicate;
	Dictionary_2_t403063CE4960B4F46C688912237C6A27E550FF55* ___s_currentActiveTasks;
	RuntimeObject* ___s_activeTasksLock;
};
struct Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572_ThreadStaticFields
{
	Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* ___t_currentTask;
	StackGuard_tACE063A1B7374BDF4AD472DE4585D05AD8745352* ___t_stackGuard;
};
struct Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC_StaticFields
{
	TaskFactory_1_t38FA2E08CB3E397D4EAEB78FF83BFC2FF0087800* ___s_defaultFactory;
};
struct Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9_StaticFields
{
	TaskFactory_1_tF4CDC5BDA20AE9BD3F65B6146CDCD3F753003E1D* ___s_defaultFactory;
};
struct Boolean_t09A6377A54BE2F9E6985A8149F19234FD7DDFE22_StaticFields
{
	String_t* ___TrueString;
	String_t* ___FalseString;
};
struct Char_t521A6F19B456D956AF452D926C32709DC03D6B17_StaticFields
{
	ByteU5BU5D_tA6237BF417AE52AD70CFB4EF24A7A82613DF9031* ___s_categoryForLatin1;
};
struct InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD_StaticFields
{
	List_1_t90832B88D7207769654164CC28440CF594CC397D* ___s_InputSubsystemCache;
};
struct IntPtr_t_StaticFields
{
	intptr_t ___Zero;
};
struct Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974_StaticFields
{
	Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974 ___identityQuaternion;
};
struct Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7_StaticFields
{
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___zeroVector;
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___oneVector;
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___upVector;
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___downVector;
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___leftVector;
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___rightVector;
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___positiveInfinityVector;
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 ___negativeInfinityVector;
};
struct Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2_StaticFields
{
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___zeroVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___oneVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___upVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___downVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___leftVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___rightVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___forwardVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___backVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___positiveInfinityVector;
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 ___negativeInfinityVector;
};
struct AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4_StaticFields
{
	Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* ___s_defaultResultTask;
};
struct Exception_t_StaticFields
{
	RuntimeObject* ___s_EDILock;
};
struct Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C_StaticFields
{
	int32_t ___OffsetOfInstanceIDInCPlusPlusObject;
};
struct Type_t_StaticFields
{
	Binder_t91BFCE95A7057FADF4D8A1A342AFE52872246235* ___s_defaultBinder;
	Il2CppChar ___Delimiter;
	TypeU5BU5D_t97234E1129B564EB38B8D85CAC2AD8B5B9522FFB* ___EmptyTypes;
	RuntimeObject* ___Missing;
	MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553* ___FilterAttribute;
	MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553* ___FilterName;
	MemberFilter_tF644F1AE82F611B677CE1964D5A3277DDA21D553* ___FilterNameIgnoreCase;
};
struct InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD_StaticFields
{
	ProfilerMarker_tA256E18DA86EDBC5528CE066FC91C96EE86501AD ___k_InputActionEnableProfilerMarker;
	ProfilerMarker_tA256E18DA86EDBC5528CE066FC91C96EE86501AD ___k_InputActionDisableProfilerMarker;
};
#ifdef __clang__
#pragma clang diagnostic pop
#endif
struct __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC  : public RuntimeArray
{
	ALIGN_FIELD (8) uint8_t m_Items[1];

	inline uint8_t* GetAddressAt(il2cpp_array_size_t index)
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		return m_Items + il2cpp_array_calc_byte_offset(this, index);
	}
	inline uint8_t* GetAddressAtUnchecked(il2cpp_array_size_t index)
	{
		return m_Items + il2cpp_array_calc_byte_offset(this, index);
	}
};
struct DelegateU5BU5D_tC5AB7E8F745616680F337909D3A8E6C722CDF771  : public RuntimeArray
{
	ALIGN_FIELD (8) Delegate_t* m_Items[1];

	inline Delegate_t* GetAt(il2cpp_array_size_t index) const
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		return m_Items[index];
	}
	inline Delegate_t** GetAddressAt(il2cpp_array_size_t index)
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		return m_Items + index;
	}
	inline void SetAt(il2cpp_array_size_t index, Delegate_t* value)
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		m_Items[index] = value;
		Il2CppCodeGenWriteBarrier((void**)m_Items + index, (void*)value);
	}
	inline Delegate_t* GetAtUnchecked(il2cpp_array_size_t index) const
	{
		return m_Items[index];
	}
	inline Delegate_t** GetAddressAtUnchecked(il2cpp_array_size_t index)
	{
		return m_Items + index;
	}
	inline void SetAtUnchecked(il2cpp_array_size_t index, Delegate_t* value)
	{
		m_Items[index] = value;
		Il2CppCodeGenWriteBarrier((void**)m_Items + index, (void*)value);
	}
};
struct Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C  : public RuntimeArray
{
	ALIGN_FIELD (8) int32_t m_Items[1];

	inline int32_t GetAt(il2cpp_array_size_t index) const
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		return m_Items[index];
	}
	inline int32_t* GetAddressAt(il2cpp_array_size_t index)
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		return m_Items + index;
	}
	inline void SetAt(il2cpp_array_size_t index, int32_t value)
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		m_Items[index] = value;
	}
	inline int32_t GetAtUnchecked(il2cpp_array_size_t index) const
	{
		return m_Items[index];
	}
	inline int32_t* GetAddressAtUnchecked(il2cpp_array_size_t index)
	{
		return m_Items + index;
	}
	inline void SetAtUnchecked(il2cpp_array_size_t index, int32_t value)
	{
		m_Items[index] = value;
	}
};
struct EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4  : public RuntimeArray
{
	ALIGN_FIELD (8) uint8_t m_Items[1];

	inline uint8_t* GetAddressAt(il2cpp_array_size_t index)
	{
		IL2CPP_ARRAY_BOUNDS_CHECK(index, (uint32_t)(this)->max_length);
		return m_Items + il2cpp_array_calc_byte_offset(this, index);
	}
	inline uint8_t* GetAddressAtUnchecked(il2cpp_array_size_t index)
	{
		return m_Items + il2cpp_array_calc_byte_offset(this, index);
	}
};


IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void TaskCompletionSource_1__ctor_m4923307A5CF439F17587173F7C04053ED22BB0C6_gshared (TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970* __this, int32_t ___0_creationOptions, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* TaskCompletionSource_1_get_Task_m4994989AA2174905CF517397D0F6B082ADC29EE9_gshared_inline (TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Result__ctor_mD5334A91B372F17CC957E2376D067FD29F493A72_gshared (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* __this, Il2CppFullySharedGenericAny ___0_argument, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool TaskCompletionSource_1_TrySetResult_m4C03ED1589D48A864F726E0FDF00D8E976DDCE0F_gshared (TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970* __this, Il2CppFullySharedGenericAny ___0_result, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Result__ctor_mA920B8E0BECD7D1B6C8AC11BEB43AD07864DB8F8_gshared (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* __this, int32_t ___0_state, ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* ___1_error, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WebCompletionSource_1_TrySetCanceled_m6069824D799921F76E03A0EED077F2E8B7090826_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662* ___0_error, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Task_1_get_Result_mF84A04F573B3700E098DF189233DA4CB3E14D53C_gshared (Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* __this, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* Result_get_Error_mA9CAACBF365B2B74E821767A0713ADA11148EC69_gshared_inline (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4 AsyncTaskMethodBuilder_1_Create_m852C283F3EAD7381A0CC8D14204899C192BDC20A_gshared (const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void AsyncTaskMethodBuilder_1_Start_TisIl2CppFullySharedGenericAny_m81177143E3D9118AF316E4C8E5D2AB2BF16C4E80_gshared (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4* __this, Il2CppFullySharedGenericAny* ___0_stateMachine, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* AsyncTaskMethodBuilder_1_get_Task_m90B072626CA4BF0F567616D4A035739B97F46D8B_gshared (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4* __this, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_gshared_inline (Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* __this, Il2CppFullySharedGenericAny ___0_arg, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A_gshared (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereArrayIterator_1__ctor_mD8BDE04F9897AAED299EE4DC32BF3879F2CBB668_gshared (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* Enumerable_CombinePredicates_TisIl2CppFullySharedGenericAny_m93E135AF98923DA7992DF8B462586C255923A45D_gshared (Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate1, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate2, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6_gshared (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* __this, RuntimeObject* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Iterator_1_Dispose_m4BA67A3D7DA249425AA8E0A0EC94AB535444D1AD_gshared (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereListIterator_1__ctor_mC075454926AF320E4679335A1B81D3F56ACEFC0C_gshared (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* __this, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void List_1_GetEnumerator_m8B2A92ACD4FBA5FBDC3F6F4F5C23A0DDF491DA61_gshared (List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* __this, Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Enumerator_get_Current_m8B42D4B2DE853B9D11B997120CD0228D4780E394_gshared_inline (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF* __this, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool Enumerator_MoveNext_m8D8E5E878AF0A88A535AB1AB5BA4F23E151A678A_gshared (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Where__ctor_m1005F36B2810D6C9BAEA784E3978689A96EB7347_gshared (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C* __this, WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* ___0_observable, RuntimeObject* ___1_observer, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereSelectArrayIterator_2__ctor_mB15DB27A8DC3B4E00BCA6E8F63F00F7E374F76A4_gshared (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereSelectEnumerableIterator_2__ctor_m9A4AF54DC527FA1CEF8B803C8DDA5E632838B06F_gshared (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* __this, RuntimeObject* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereSelectListIterator_2__ctor_m6BFCBB5460270ED1896D24DC7E3B83F4950D2140_gshared (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336* __this, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1__ctor_m7AC3CC7AABC83B76D23D2B94329DD4D0200156FA_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcStart, int32_t ___2_srcLen, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1__ctor_mFEB81358558CEF0264CCE077535DB880EA2492BA_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcLen, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1_get_Item_mFDEC427E08156ECD6879AD45AEE3618B43E3F726_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, int32_t ___0_index, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1_set_Item_m757F8BE76FAE27C149DE7C474A2B1845E08A5A0F_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, int32_t ___0_index, Il2CppFullySharedGenericAny ___1_value, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t WorkSlice_1_get_length_m7212817506EACBA1AB0D914DE401C6FA05F0DD9D_gshared_inline (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t WorkSlice_1_get_capacity_mCF0D603B7EC6E6037D0E1A14D8D0F49AD063E59E_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Sorting_QuickSort_TisIl2CppFullySharedGenericAny_mFECEFDEFE0154FD35AB3600D1EC1BCA3688FB81D_gshared (__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_data, int32_t ___1_start, int32_t ___2_end, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9* ___3_compare, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1_Sort_mE2ED392BDF8F4F4141D7BF4C984EFE943F607A94_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9* ___0_compare, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR String_t* ExtractKeyDelegate_Invoke_m299616CF7575CD317723CE89D3BA8B8F04A9B722_gshared_inline (ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* __this, Il2CppFullySharedGenericAny ___0_value, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XHashtableState__ctor_mC2ED3CAB78829509332331B146E7165C58D3DD0F_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* ___0_extractKey, int32_t ___1_capacity, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XHashtableState_TryAdd_m25BEF4B433B3B23CE79C25AA27DA2FFB624CCAE2_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, Il2CppFullySharedGenericAny ___0_value, Il2CppFullySharedGenericAny* ___1_newValue, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t XHashtableState_ComputeHashCode_m52BA0BD18441AD2A49C4E822AB76A7A5B7DC4B6D_gshared (String_t* ___0_key, int32_t ___1_index, int32_t ___2_count, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XHashtableState_FindEntry_m480C6B27D99709A7E6CB50C907ACDEA057992BCD_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, int32_t ___0_hashCode, String_t* ___1_key, int32_t ___2_index, int32_t ___3_count, int32_t* ___4_entryIndex, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XHashtableState_TryGetValue_m94EE8AEAE527C34D9D2B86D03E1D04FF867266F3_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, String_t* ___0_key, int32_t ___1_index, int32_t ___2_count, Il2CppFullySharedGenericAny* ___3_value, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* XHashtableState_Resize_m3CD152F50AD9E53B808C9B1CEC069D894A621202_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR String_t* InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_gshared_inline (InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared (InputFeatureUsage_1_t8FA831CB65EB7520D33B55F11443959DE72B2F8C* __this, String_t* ___0_usageName, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityObjectReferenceCache_2__ctor_mC730139AB089ECA2FDF57B0ED0F5787D3A645A76_gshared (UnityObjectReferenceCache_2_tDDA23E8D68929712BE24F100B89ED0291001D0DB* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* UnityObjectReferenceCache_2_Get_mD207A47F306631DFF54E2DB96937C2CB8C268B89_gshared (UnityObjectReferenceCache_2_tDDA23E8D68929712BE24F100B89ED0291001D0DB* __this, RuntimeObject* ___0_field, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void UnityObjectReferenceCache_2_Set_mD396221283F2C35D820D096F1D1B74C1D3ACB36D_gshared (UnityObjectReferenceCache_2_tDDA23E8D68929712BE24F100B89ED0291001D0DB* __this, RuntimeObject** ___0_field, RuntimeObject* ___1_value, const RuntimeMethod* method) ;
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR RuntimeObject* XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_gshared_inline (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void BypassScope__ctor_mAFDCC84D1B05DD11FE45CA5C33454771613E01D5_gshared (BypassScope_t801793A02437762F196198D282A1980396D8B968* __this, XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* ___0_reader, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void BypassScope_Dispose_mD2092263EF1CD137EB35D092B66915B2A0EFDE40_gshared (BypassScope_t801793A02437762F196198D282A1980396D8B968* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1_ReadValue_mA9DD9A98276A883692B7BCBDFBAB6912D60F41E9_gshared (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___0_action, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* XRInputValueReader_1_GetObjectReference_m3BED8195FBDCE6A99FCC116EBDC1EB0D62D2A039_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputValueReader_1_TryReadValue_mAF814AE91F21FF5F3AD73616B7D14DB1CAD004D6_gshared (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___0_action, Il2CppFullySharedGenericStruct* ___1_value, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void InputAction_ReadValue_TisIl2CppFullySharedGenericStruct_m0B8C6490DD8EE673339E603898F5BB14254C3DBD_gshared (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method) ;

IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2 (RuntimeObject* __this, const RuntimeMethod* method) ;
inline void TaskCompletionSource_1__ctor_m66A94FA06482E1BF022E155A1243802F3BCEAD7C (TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* __this, int32_t ___0_creationOptions, const RuntimeMethod* method)
{
	((  void (*) (TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7*, int32_t, const RuntimeMethod*))TaskCompletionSource_1__ctor_m4923307A5CF439F17587173F7C04053ED22BB0C6_gshared)(__this, ___0_creationOptions, method);
}
inline Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* TaskCompletionSource_1_get_Task_m99C4E7D405DA7485360F4554AD219A778BBED3C7_inline (TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* __this, const RuntimeMethod* method)
{
	return ((  Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* (*) (TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7*, const RuntimeMethod*))TaskCompletionSource_1_get_Task_m4994989AA2174905CF517397D0F6B082ADC29EE9_gshared_inline)(__this, method);
}
inline void Result__ctor_mD5334A91B372F17CC957E2376D067FD29F493A72 (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* __this, Il2CppFullySharedGenericAny ___0_argument, const RuntimeMethod* method)
{
	((  void (*) (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*, Il2CppFullySharedGenericAny, const RuntimeMethod*))Result__ctor_mD5334A91B372F17CC957E2376D067FD29F493A72_gshared)((Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)__this, ___0_argument, method);
}
inline bool TaskCompletionSource_1_TrySetResult_m6421F3166CAE62DBE3D5B5C203F0399644E004A1 (TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* __this, Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* ___0_result, const RuntimeMethod* method)
{
	return ((  bool (*) (TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970*, Il2CppFullySharedGenericAny, const RuntimeMethod*))TaskCompletionSource_1_TrySetResult_m4C03ED1589D48A864F726E0FDF00D8E976DDCE0F_gshared)((TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970*)__this, (Il2CppFullySharedGenericAny)___0_result, method);
}
inline void Result__ctor_mA920B8E0BECD7D1B6C8AC11BEB43AD07864DB8F8 (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* __this, int32_t ___0_state, ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* ___1_error, const RuntimeMethod* method)
{
	((  void (*) (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*, int32_t, ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757*, const RuntimeMethod*))Result__ctor_mA920B8E0BECD7D1B6C8AC11BEB43AD07864DB8F8_gshared)(__this, ___0_state, ___1_error, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void OperationCanceledException__ctor_m2F34C3B8AEE2AA6C7EB2BB77AE5E0289101293E4 (OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662* __this, const RuntimeMethod* method) ;
inline bool WebCompletionSource_1_TrySetCanceled_m6069824D799921F76E03A0EED077F2E8B7090826 (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662* ___0_error, const RuntimeMethod* method)
{
	return ((  bool (*) (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F*, OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662*, const RuntimeMethod*))WebCompletionSource_1_TrySetCanceled_m6069824D799921F76E03A0EED077F2E8B7090826_gshared)(__this, ___0_error, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* ExceptionDispatchInfo_Capture_mC1C1C30D83DC04B2B7813DFCB67D07CCD4909803 (Exception_t* ___0_source, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool Task_get_IsCompleted_m942D6D536545EF059089398B19435591561BB831 (Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* __this, const RuntimeMethod* method) ;
inline Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* Task_1_get_Result_m4BD43EF8B903D5FEDED967167DB07B2941B7E6C9 (Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* __this, const RuntimeMethod* method)
{
	Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* il2cppRetVal;
	((  void (*) (Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))Task_1_get_Result_mF84A04F573B3700E098DF189233DA4CB3E14D53C_gshared)((Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9*)__this, (Il2CppFullySharedGenericAny*)&il2cppRetVal, method);
	return il2cppRetVal;
}
inline ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* Result_get_Error_mA9CAACBF365B2B74E821767A0713ADA11148EC69_inline (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* __this, const RuntimeMethod* method)
{
	return ((  ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* (*) (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*, const RuntimeMethod*))Result_get_Error_mA9CAACBF365B2B74E821767A0713ADA11148EC69_gshared_inline)(__this, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void ExceptionDispatchInfo_Throw_m06F398E346AE94C1CCEB636763A8CB26511F6330 (ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* __this, const RuntimeMethod* method) ;
inline AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4 AsyncTaskMethodBuilder_1_Create_m852C283F3EAD7381A0CC8D14204899C192BDC20A (const RuntimeMethod* method)
{
	return ((  AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4 (*) (const RuntimeMethod*))AsyncTaskMethodBuilder_1_Create_m852C283F3EAD7381A0CC8D14204899C192BDC20A_gshared)(method);
}
inline void AsyncTaskMethodBuilder_1_Start_TisU3CWaitForCompletionU3Ed__15_t1E7A90912CE0FB4BBFDADC017893E65373B96937_m38C56B931D2323D0F0219A4AFDBC6416FA04D52A (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4* __this, U3CWaitForCompletionU3Ed__15_t1E7A90912CE0FB4BBFDADC017893E65373B96937* ___0_stateMachine, const RuntimeMethod* method)
{
	((  void (*) (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4*, U3CWaitForCompletionU3Ed__15_t1E7A90912CE0FB4BBFDADC017893E65373B96937*, const RuntimeMethod*))AsyncTaskMethodBuilder_1_Start_TisIl2CppFullySharedGenericAny_m81177143E3D9118AF316E4C8E5D2AB2BF16C4E80_gshared)(__this, ___0_stateMachine, method);
}
inline Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* AsyncTaskMethodBuilder_1_get_Task_m90B072626CA4BF0F567616D4A035739B97F46D8B (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4* __this, const RuntimeMethod* method)
{
	return ((  Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* (*) (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4*, const RuntimeMethod*))AsyncTaskMethodBuilder_1_get_Task_m90B072626CA4BF0F567616D4A035739B97F46D8B_gshared)(__this, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Debug_LogException_mAB3F4DC7297ED8FBB49DAA718B70E59A6B0171B0 (Exception_t* ___0_exception, const RuntimeMethod* method) ;
inline bool Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline (Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* __this, Il2CppFullySharedGenericAny ___0_arg, const RuntimeMethod* method)
{
	bool il2cppRetVal;
	((  void (*) (Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*, Il2CppFullySharedGenericAny, Il2CppFullySharedGenericAny*, const RuntimeMethod*))Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_gshared_inline)((Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*)__this, ___0_arg, (Il2CppFullySharedGenericAny*)&il2cppRetVal, method);
	return il2cppRetVal;
}
inline void Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* __this, const RuntimeMethod* method)
{
	((  void (*) (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*, const RuntimeMethod*))Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A_gshared)(__this, method);
}
inline void WhereArrayIterator_1__ctor_mD8BDE04F9897AAED299EE4DC32BF3879F2CBB668 (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method)
{
	((  void (*) (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6*, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC*, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, const RuntimeMethod*))WhereArrayIterator_1__ctor_mD8BDE04F9897AAED299EE4DC32BF3879F2CBB668_gshared)(__this, ___0_source, ___1_predicate, method);
}
inline Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* Enumerable_CombinePredicates_TisIl2CppFullySharedGenericAny_m93E135AF98923DA7992DF8B462586C255923A45D (Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate1, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate2, const RuntimeMethod* method)
{
	return ((  Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* (*) (Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, const RuntimeMethod*))Enumerable_CombinePredicates_TisIl2CppFullySharedGenericAny_m93E135AF98923DA7992DF8B462586C255923A45D_gshared)(___0_predicate1, ___1_predicate2, method);
}
inline void WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6 (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* __this, RuntimeObject* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method)
{
	((  void (*) (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B*, RuntimeObject*, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, const RuntimeMethod*))WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6_gshared)(__this, ___0_source, ___1_predicate, method);
}
inline void Iterator_1_Dispose_m4BA67A3D7DA249425AA8E0A0EC94AB535444D1AD (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* __this, const RuntimeMethod* method)
{
	((  void (*) (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*, const RuntimeMethod*))Iterator_1_Dispose_m4BA67A3D7DA249425AA8E0A0EC94AB535444D1AD_gshared)(__this, method);
}
inline void WhereListIterator_1__ctor_mC075454926AF320E4679335A1B81D3F56ACEFC0C (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* __this, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method)
{
	((  void (*) (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0*, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A*, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, const RuntimeMethod*))WhereListIterator_1__ctor_mC075454926AF320E4679335A1B81D3F56ACEFC0C_gshared)(__this, ___0_source, ___1_predicate, method);
}
inline void List_1_GetEnumerator_m8B2A92ACD4FBA5FBDC3F6F4F5C23A0DDF491DA61 (List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* __this, Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A*, Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*, const RuntimeMethod*))List_1_GetEnumerator_m8B2A92ACD4FBA5FBDC3F6F4F5C23A0DDF491DA61_gshared)((List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A*)__this, il2cppRetVal, method);
}
inline void Enumerator_get_Current_m8B42D4B2DE853B9D11B997120CD0228D4780E394_inline (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF* __this, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*, Il2CppFullySharedGenericAny*, const RuntimeMethod*))Enumerator_get_Current_m8B42D4B2DE853B9D11B997120CD0228D4780E394_gshared_inline)((Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*)__this, il2cppRetVal, method);
}
inline bool Enumerator_MoveNext_m8D8E5E878AF0A88A535AB1AB5BA4F23E151A678A (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF* __this, const RuntimeMethod* method)
{
	return ((  bool (*) (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*, const RuntimeMethod*))Enumerator_MoveNext_m8D8E5E878AF0A88A535AB1AB5BA4F23E151A678A_gshared)(__this, method);
}
inline void Where__ctor_m1005F36B2810D6C9BAEA784E3978689A96EB7347 (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C* __this, WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* ___0_observable, RuntimeObject* ___1_observer, const RuntimeMethod* method)
{
	((  void (*) (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C*, WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816*, RuntimeObject*, const RuntimeMethod*))Where__ctor_m1005F36B2810D6C9BAEA784E3978689A96EB7347_gshared)(__this, ___0_observable, ___1_observer, method);
}
inline void WhereSelectArrayIterator_2__ctor_mB15DB27A8DC3B4E00BCA6E8F63F00F7E374F76A4 (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method)
{
	((  void (*) (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174*, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC*, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*, const RuntimeMethod*))WhereSelectArrayIterator_2__ctor_mB15DB27A8DC3B4E00BCA6E8F63F00F7E374F76A4_gshared)(__this, ___0_source, ___1_predicate, ___2_selector, method);
}
inline void Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_inline (Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* __this, Il2CppFullySharedGenericAny ___0_arg, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*, Il2CppFullySharedGenericAny, Il2CppFullySharedGenericAny*, const RuntimeMethod*))Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_gshared_inline)((Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*)__this, ___0_arg, il2cppRetVal, method);
}
inline void WhereSelectEnumerableIterator_2__ctor_m9A4AF54DC527FA1CEF8B803C8DDA5E632838B06F (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* __this, RuntimeObject* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method)
{
	((  void (*) (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C*, RuntimeObject*, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*, const RuntimeMethod*))WhereSelectEnumerableIterator_2__ctor_m9A4AF54DC527FA1CEF8B803C8DDA5E632838B06F_gshared)(__this, ___0_source, ___1_predicate, ___2_selector, method);
}
inline void WhereSelectListIterator_2__ctor_m6BFCBB5460270ED1896D24DC7E3B83F4950D2140 (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336* __this, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method)
{
	((  void (*) (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336*, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A*, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*, const RuntimeMethod*))WhereSelectListIterator_2__ctor_m6BFCBB5460270ED1896D24DC7E3B83F4950D2140_gshared)(__this, ___0_source, ___1_predicate, ___2_selector, method);
}
inline void WorkSlice_1__ctor_m7AC3CC7AABC83B76D23D2B94329DD4D0200156FA (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcStart, int32_t ___2_srcLen, const RuntimeMethod* method)
{
	((  void (*) (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC*, int32_t, int32_t, const RuntimeMethod*))WorkSlice_1__ctor_m7AC3CC7AABC83B76D23D2B94329DD4D0200156FA_gshared)(__this, ___0_src, ___1_srcStart, ___2_srcLen, method);
}
inline void WorkSlice_1__ctor_mFEB81358558CEF0264CCE077535DB880EA2492BA (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcLen, const RuntimeMethod* method)
{
	((  void (*) (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC*, int32_t, const RuntimeMethod*))WorkSlice_1__ctor_mFEB81358558CEF0264CCE077535DB880EA2492BA_gshared)(__this, ___0_src, ___1_srcLen, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Math_Min_m53C488772A34D53917BCA2A491E79A0A5356ED52 (int32_t ___0_val1, int32_t ___1_val2, const RuntimeMethod* method) ;
inline void WorkSlice_1_get_Item_mFDEC427E08156ECD6879AD45AEE3618B43E3F726 (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, int32_t ___0_index, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*, int32_t, Il2CppFullySharedGenericAny*, const RuntimeMethod*))WorkSlice_1_get_Item_mFDEC427E08156ECD6879AD45AEE3618B43E3F726_gshared)((WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*)__this, ___0_index, il2cppRetVal, method);
}
inline void WorkSlice_1_set_Item_m757F8BE76FAE27C149DE7C474A2B1845E08A5A0F (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, int32_t ___0_index, Il2CppFullySharedGenericAny ___1_value, const RuntimeMethod* method)
{
	((  void (*) (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*, int32_t, Il2CppFullySharedGenericAny, const RuntimeMethod*))WorkSlice_1_set_Item_m757F8BE76FAE27C149DE7C474A2B1845E08A5A0F_gshared)((WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*)__this, ___0_index, ___1_value, method);
}
inline int32_t WorkSlice_1_get_length_m7212817506EACBA1AB0D914DE401C6FA05F0DD9D_inline (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, const RuntimeMethod* method)
{
	return ((  int32_t (*) (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*, const RuntimeMethod*))WorkSlice_1_get_length_m7212817506EACBA1AB0D914DE401C6FA05F0DD9D_gshared_inline)(__this, method);
}
inline int32_t WorkSlice_1_get_capacity_mCF0D603B7EC6E6037D0E1A14D8D0F49AD063E59E (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, const RuntimeMethod* method)
{
	return ((  int32_t (*) (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*, const RuntimeMethod*))WorkSlice_1_get_capacity_mCF0D603B7EC6E6037D0E1A14D8D0F49AD063E59E_gshared)(__this, method);
}
inline void Sorting_QuickSort_TisIl2CppFullySharedGenericAny_mFECEFDEFE0154FD35AB3600D1EC1BCA3688FB81D (__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_data, int32_t ___1_start, int32_t ___2_end, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9* ___3_compare, const RuntimeMethod* method)
{
	((  void (*) (__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC*, int32_t, int32_t, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9*, const RuntimeMethod*))Sorting_QuickSort_TisIl2CppFullySharedGenericAny_mFECEFDEFE0154FD35AB3600D1EC1BCA3688FB81D_gshared)(___0_data, ___1_start, ___2_end, ___3_compare, method);
}
inline void WorkSlice_1_Sort_mE2ED392BDF8F4F4141D7BF4C984EFE943F607A94 (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9* ___0_compare, const RuntimeMethod* method)
{
	((  void (*) (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9*, const RuntimeMethod*))WorkSlice_1_Sort_mE2ED392BDF8F4F4141D7BF4C984EFE943F607A94_gshared)(__this, ___0_compare, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Interlocked_CompareExchange_mB06E8737D3DA41F9FFBC38A6D0583D515EFB5717 (int32_t* ___0_location1, int32_t ___1_value, int32_t ___2_comparand, const RuntimeMethod* method) ;
inline String_t* ExtractKeyDelegate_Invoke_m299616CF7575CD317723CE89D3BA8B8F04A9B722_inline (ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* __this, Il2CppFullySharedGenericAny ___0_value, const RuntimeMethod* method)
{
	return ((  String_t* (*) (ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD*, Il2CppFullySharedGenericAny, const RuntimeMethod*))ExtractKeyDelegate_Invoke_m299616CF7575CD317723CE89D3BA8B8F04A9B722_gshared_inline)((ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD*)__this, ___0_value, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void OverflowException__ctor_m7F6A928C9BE47384586BDDE8B4B87666421E0F1A (OverflowException_t6F6AD8CACE20C37F701C05B373A215C4802FAB0C* __this, const RuntimeMethod* method) ;
inline void XHashtableState__ctor_mC2ED3CAB78829509332331B146E7165C58D3DD0F (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* ___0_extractKey, int32_t ___1_capacity, const RuntimeMethod* method)
{
	((  void (*) (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*, ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD*, int32_t, const RuntimeMethod*))XHashtableState__ctor_mC2ED3CAB78829509332331B146E7165C58D3DD0F_gshared)(__this, ___0_extractKey, ___1_capacity, method);
}
inline bool XHashtableState_TryAdd_m25BEF4B433B3B23CE79C25AA27DA2FFB624CCAE2 (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, Il2CppFullySharedGenericAny ___0_value, Il2CppFullySharedGenericAny* ___1_newValue, const RuntimeMethod* method)
{
	return ((  bool (*) (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*, Il2CppFullySharedGenericAny, Il2CppFullySharedGenericAny*, const RuntimeMethod*))XHashtableState_TryAdd_m25BEF4B433B3B23CE79C25AA27DA2FFB624CCAE2_gshared)((XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*)__this, ___0_value, ___1_newValue, method);
}
inline int32_t XHashtableState_ComputeHashCode_m52BA0BD18441AD2A49C4E822AB76A7A5B7DC4B6D (String_t* ___0_key, int32_t ___1_index, int32_t ___2_count, const RuntimeMethod* method)
{
	return ((  int32_t (*) (String_t*, int32_t, int32_t, const RuntimeMethod*))XHashtableState_ComputeHashCode_m52BA0BD18441AD2A49C4E822AB76A7A5B7DC4B6D_gshared)(___0_key, ___1_index, ___2_count, method);
}
inline bool XHashtableState_FindEntry_m480C6B27D99709A7E6CB50C907ACDEA057992BCD (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, int32_t ___0_hashCode, String_t* ___1_key, int32_t ___2_index, int32_t ___3_count, int32_t* ___4_entryIndex, const RuntimeMethod* method)
{
	return ((  bool (*) (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*, int32_t, String_t*, int32_t, int32_t, int32_t*, const RuntimeMethod*))XHashtableState_FindEntry_m480C6B27D99709A7E6CB50C907ACDEA057992BCD_gshared)(__this, ___0_hashCode, ___1_key, ___2_index, ___3_count, ___4_entryIndex, method);
}
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t String_get_Length_m42625D67623FA5CC7A44D47425CE86FB946542D2_inline (String_t* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t Interlocked_Increment_m3C240C32E8D9544EC050B74D4F28EEB58F1F9309 (int32_t* ___0_location, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Thread_MemoryBarrier_m83873F1E6CEB16C0781941141382DA874A36097D (const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t String_CompareOrdinal_m8940CFAE90021ED8DA3F2DF8226941C9EEB2E32D (String_t* ___0_strA, int32_t ___1_indexA, String_t* ___2_strB, int32_t ___3_indexB, int32_t ___4_length, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Il2CppChar String_get_Chars_mC49DF0CD2D3BE7BE97B3AD9C995BE3094F8E36D3 (String_t* __this, int32_t ___0_index, const RuntimeMethod* method) ;
inline bool XHashtableState_TryGetValue_m94EE8AEAE527C34D9D2B86D03E1D04FF867266F3 (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, String_t* ___0_key, int32_t ___1_index, int32_t ___2_count, Il2CppFullySharedGenericAny* ___3_value, const RuntimeMethod* method)
{
	return ((  bool (*) (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*, String_t*, int32_t, int32_t, Il2CppFullySharedGenericAny*, const RuntimeMethod*))XHashtableState_TryGetValue_m94EE8AEAE527C34D9D2B86D03E1D04FF867266F3_gshared)(__this, ___0_key, ___1_index, ___2_count, ___3_value, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Monitor_Exit_m05B2CF037E2214B3208198C282490A2A475653FA (RuntimeObject* ___0_obj, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Monitor_Enter_m3CDB589DA1300B513D55FDCFB52B63E879794149 (RuntimeObject* ___0_obj, bool* ___1_lockTaken, const RuntimeMethod* method) ;
inline XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* XHashtableState_Resize_m3CD152F50AD9E53B808C9B1CEC069D894A621202 (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, const RuntimeMethod* method)
{
	return ((  XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* (*) (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*, const RuntimeMethod*))XHashtableState_Resize_m3CD152F50AD9E53B808C9B1CEC069D894A621202_gshared)(__this, method);
}
inline bool XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method)
{
	return ((  bool (*) (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1*, const RuntimeMethod*))XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E_gshared)(__this, method);
}
inline String_t* InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline (InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* __this, const RuntimeMethod* method)
{
	return ((  String_t* (*) (InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB*, const RuntimeMethod*))InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_gshared_inline)(__this, method);
}
inline void InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7 (InputFeatureUsage_1_tE336B2F0B9AC721519BFA17A08D6353FD5221637* __this, String_t* ___0_usageName, const RuntimeMethod* method)
{
	((  void (*) (InputFeatureUsage_1_tE336B2F0B9AC721519BFA17A08D6353FD5221637*, String_t*, const RuntimeMethod*))InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared)(__this, ___0_usageName, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_TryGetFeatureValue_m24EC3B6C41AE4098269427232AD5F52E786BF884 (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, InputFeatureUsage_1_tE336B2F0B9AC721519BFA17A08D6353FD5221637 ___0_usage, bool* ___1_value, const RuntimeMethod* method) ;
inline void InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0 (InputFeatureUsage_1_tD73AC74B29139087A83959CB3395A0580A2128AE* __this, String_t* ___0_usageName, const RuntimeMethod* method)
{
	((  void (*) (InputFeatureUsage_1_tD73AC74B29139087A83959CB3395A0580A2128AE*, String_t*, const RuntimeMethod*))InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared)(__this, ___0_usageName, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_TryGetFeatureValue_m9FC969BEFF0E5BAB78DD9F2130F437788D20068C (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, InputFeatureUsage_1_tD73AC74B29139087A83959CB3395A0580A2128AE ___0_usage, uint32_t* ___1_value, const RuntimeMethod* method) ;
inline void InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989 (InputFeatureUsage_1_t311D0F42F1A7BF37D3CEAC15A53A1F24165F1848* __this, String_t* ___0_usageName, const RuntimeMethod* method)
{
	((  void (*) (InputFeatureUsage_1_t311D0F42F1A7BF37D3CEAC15A53A1F24165F1848*, String_t*, const RuntimeMethod*))InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared)(__this, ___0_usageName, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_TryGetFeatureValue_m675D52240379FEF80D6499B5031941812FDFD081 (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, InputFeatureUsage_1_t311D0F42F1A7BF37D3CEAC15A53A1F24165F1848 ___0_usage, float* ___1_value, const RuntimeMethod* method) ;
inline void InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A (InputFeatureUsage_1_tEB160A05BCDCCA4F96072CBA0866498D06B9A27C* __this, String_t* ___0_usageName, const RuntimeMethod* method)
{
	((  void (*) (InputFeatureUsage_1_tEB160A05BCDCCA4F96072CBA0866498D06B9A27C*, String_t*, const RuntimeMethod*))InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared)(__this, ___0_usageName, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_TryGetFeatureValue_mB2C15D1FC747DA9FB5958FA17E77049886FB3BBA (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, InputFeatureUsage_1_tEB160A05BCDCCA4F96072CBA0866498D06B9A27C ___0_usage, Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7* ___1_value, const RuntimeMethod* method) ;
inline void InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA (InputFeatureUsage_1_t2E901FA41650EB29399194768CAA93D477CEBC58* __this, String_t* ___0_usageName, const RuntimeMethod* method)
{
	((  void (*) (InputFeatureUsage_1_t2E901FA41650EB29399194768CAA93D477CEBC58*, String_t*, const RuntimeMethod*))InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared)(__this, ___0_usageName, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_TryGetFeatureValue_m472B5ECE996FB7440CACCF1E85722DA4963E3167 (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, InputFeatureUsage_1_t2E901FA41650EB29399194768CAA93D477CEBC58 ___0_usage, Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2* ___1_value, const RuntimeMethod* method) ;
inline void InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08 (InputFeatureUsage_1_t8489CEC68B1EC178F2634079A9D7CD9E90D3CF5D* __this, String_t* ___0_usageName, const RuntimeMethod* method)
{
	((  void (*) (InputFeatureUsage_1_t8489CEC68B1EC178F2634079A9D7CD9E90D3CF5D*, String_t*, const RuntimeMethod*))InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared)(__this, ___0_usageName, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_TryGetFeatureValue_m0C1A9761DD0D1C6D1EF4BAB2FAF1BC1A9541BB9F (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, InputFeatureUsage_1_t8489CEC68B1EC178F2634079A9D7CD9E90D3CF5D ___0_usage, Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974* ___1_value, const RuntimeMethod* method) ;
inline void InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55 (InputFeatureUsage_1_t4EF7DDCAC35EE23BA72694AC2AB76CF4A879FFD9* __this, String_t* ___0_usageName, const RuntimeMethod* method)
{
	((  void (*) (InputFeatureUsage_1_t4EF7DDCAC35EE23BA72694AC2AB76CF4A879FFD9*, String_t*, const RuntimeMethod*))InputFeatureUsage_1__ctor_mAE978CC133E57B40C2D810A714714CC92408E485_gshared)(__this, ___0_usageName, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_TryGetFeatureValue_m8A01F07356DC85042F6BB7C6258A75C3EC3C4E11 (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, InputFeatureUsage_1_t4EF7DDCAC35EE23BA72694AC2AB76CF4A879FFD9 ___0_usage, uint32_t* ___1_value, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputDevice_get_isValid_mA908CF8195CECA44FF457430AFF9198C3FEC0948 (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputTrackingAggregator_TryGetDeviceWithExactCharacteristics_mECEA5AB0B5B089CD481FC654BA081484A967647A (uint32_t ___0_desiredCharacteristics, InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* ___1_inputDevice, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputDeviceValueReader__ctor_m5F34B83F8DA1BD97773ED8301A966D2E2891F757 (XRInputDeviceValueReader_t91D732DACFC1260DE12B5C0EA0CE33B0EAF2581A* __this, const RuntimeMethod* method) ;
inline void UnityObjectReferenceCache_2__ctor_mF3CC554EC436AA061C6D2F3D93C5ECD2D33FC91E (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D* __this, const RuntimeMethod* method)
{
	((  void (*) (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D*, const RuntimeMethod*))UnityObjectReferenceCache_2__ctor_mC730139AB089ECA2FDF57B0ED0F5787D3A645A76_gshared)(__this, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader__ctor_mF80B938FCE31DD85F0E3048DC60D969C2E50A296 (XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59* __this, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Type_t* Type_GetTypeFromHandle_m6062B81682F79A4D6DF2640692EE6D9987858C57 (RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B ___0_handle, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* InputActionUtility_CreateValueAction_mF7C1DCF322EBC2C0478B2F0502AF265CBC570032 (Type_t* ___0_valueType, String_t* ___1_name, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader__ctor_mAFED8EF378777B7CB3C92AE4ED4FE6130C2A2A6F (XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59* __this, InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___0_inputAction, int32_t ___1_inputSourceMode, const RuntimeMethod* method) ;
inline RuntimeObject* UnityObjectReferenceCache_2_Get_mB6216FA3FF646BEC3525A47E5BADC61CE380DB8E (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D* __this, Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C* ___0_field, const RuntimeMethod* method)
{
	return ((  RuntimeObject* (*) (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D*, Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C*, const RuntimeMethod*))UnityObjectReferenceCache_2_Get_mD207A47F306631DFF54E2DB96937C2CB8C268B89_gshared)(__this, ___0_field, method);
}
inline void UnityObjectReferenceCache_2_Set_mB32C421F461C529EEB9C7A74C95AC57CB41A44DF (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D* __this, Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C** ___0_field, RuntimeObject* ___1_value, const RuntimeMethod* method)
{
	((  void (*) (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D*, Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C**, RuntimeObject*, const RuntimeMethod*))UnityObjectReferenceCache_2_Set_mD396221283F2C35D820D096F1D1B74C1D3ACB36D_gshared)(__this, ___0_field, ___1_value, method);
}
inline RuntimeObject* XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_inline (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method)
{
	return ((  RuntimeObject* (*) (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F*, const RuntimeMethod*))XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_gshared_inline)(__this, method);
}
inline void BypassScope__ctor_mAFDCC84D1B05DD11FE45CA5C33454771613E01D5 (BypassScope_t801793A02437762F196198D282A1980396D8B968* __this, XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* ___0_reader, const RuntimeMethod* method)
{
	((  void (*) (BypassScope_t801793A02437762F196198D282A1980396D8B968*, XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F*, const RuntimeMethod*))BypassScope__ctor_mAFDCC84D1B05DD11FE45CA5C33454771613E01D5_gshared)(__this, ___0_reader, method);
}
inline void BypassScope_Dispose_mD2092263EF1CD137EB35D092B66915B2A0EFDE40 (BypassScope_t801793A02437762F196198D282A1980396D8B968* __this, const RuntimeMethod* method)
{
	((  void (*) (BypassScope_t801793A02437762F196198D282A1980396D8B968*, const RuntimeMethod*))BypassScope_Dispose_mD2092263EF1CD137EB35D092B66915B2A0EFDE40_gshared)(__this, method);
}
inline void XRInputValueReader_1_ReadValue_mA9DD9A98276A883692B7BCBDFBAB6912D60F41E9 (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___0_action, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))XRInputValueReader_1_ReadValue_mA9DD9A98276A883692B7BCBDFBAB6912D60F41E9_gshared)(___0_action, il2cppRetVal, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputValueReader_TryGetInputActionReference_mD39365C3DCD6A92BCCD9918EF4919D075CF17806 (XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59* __this, InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1** ___0_reference, const RuntimeMethod* method) ;
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* InputActionReference_get_action_m395EDEA6A93B54555D22323FDA6E1B1E931CE6EF (InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1* __this, const RuntimeMethod* method) ;
inline RuntimeObject* XRInputValueReader_1_GetObjectReference_m3BED8195FBDCE6A99FCC116EBDC1EB0D62D2A039 (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method)
{
	return ((  RuntimeObject* (*) (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F*, const RuntimeMethod*))XRInputValueReader_1_GetObjectReference_m3BED8195FBDCE6A99FCC116EBDC1EB0D62D2A039_gshared)(__this, method);
}
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t XRInputValueReader_get_inputSourceMode_m6D12A254104BBE6F3945ACFE6CAC42DC51CDD5E0_inline (XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59* __this, const RuntimeMethod* method) ;
inline bool XRInputValueReader_1_TryReadValue_mAF814AE91F21FF5F3AD73616B7D14DB1CAD004D6 (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___0_action, Il2CppFullySharedGenericStruct* ___1_value, const RuntimeMethod* method)
{
	return ((  bool (*) (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))XRInputValueReader_1_TryReadValue_mAF814AE91F21FF5F3AD73616B7D14DB1CAD004D6_gshared)(___0_action, ___1_value, method);
}
inline void InputAction_ReadValue_TisIl2CppFullySharedGenericStruct_m0B8C6490DD8EE673339E603898F5BB14254C3DBD (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method)
{
	((  void (*) (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD*, Il2CppFullySharedGenericStruct*, const RuntimeMethod*))InputAction_ReadValue_TisIl2CppFullySharedGenericStruct_m0B8C6490DD8EE673339E603898F5BB14254C3DBD_gshared)((InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD*)__this, il2cppRetVal, method);
}
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool InputAction_IsInProgress_m0572B3C5AA6C8E7FC4A1927DDAA54C3D40714E62 (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* __this, const RuntimeMethod* method) ;
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 62143
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WebCompletionSource_1__ctor_m13CEDC0A86393FB85F2E66EA67014C70C41083EE_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, bool ___0_runAsync, const RuntimeMethod* method) 
{
	WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* G_B2_0 = NULL;
	WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* G_B1_0 = NULL;
	int32_t G_B3_0 = 0;
	WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* G_B3_1 = NULL;
	{
		Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2((RuntimeObject*)__this, NULL);
		bool L_0 = ___0_runAsync;
		if (L_0)
		{
			G_B2_0 = __this;
			goto IL_000d;
		}
		G_B1_0 = __this;
	}
	{
		G_B3_0 = 0;
		G_B3_1 = G_B1_0;
		goto IL_000f;
	}

IL_000d:
	{
		G_B3_0 = ((int32_t)64);
		G_B3_1 = G_B2_0;
	}

IL_000f:
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_1 = (TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 0));
		TaskCompletionSource_1__ctor_m66A94FA06482E1BF022E155A1243802F3BCEAD7C(L_1, (int32_t)G_B3_0, il2cpp_rgctx_method(method->klass->rgctx_data, 1));
		NullCheck(G_B3_1);
		G_B3_1->___completion = L_1;
		Il2CppCodeGenWriteBarrier((void**)(&G_B3_1->___completion), (void*)L_1);
		return;
	}
}
// Method Definition Index: 62144
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* WebCompletionSource_1_get_CurrentResult_mC1D6F5E4169EAEC90D7E02EEC2DD3FF7087EC035_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, const RuntimeMethod* method) 
{
	{
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_0 = __this->___currentResult;
		return L_0;
	}
}
// Method Definition Index: 62145
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572* WebCompletionSource_1_get_Task_mABFED18FF1EB8709C0110FA07D888A52F950367D_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, const RuntimeMethod* method) 
{
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_0 = __this->___completion;
		NullCheck(L_0);
		Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* L_1;
		L_1 = TaskCompletionSource_1_get_Task_m99C4E7D405DA7485360F4554AD219A778BBED3C7_inline(L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 4));
		return (Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572*)L_1;
	}
}
// Method Definition Index: 62146
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WebCompletionSource_1_TrySetCompleted_m3E4132773ACAE17F3953CB76254F5C922FFB31B7_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, Il2CppFullySharedGenericAny ___0_argument, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_T_t2650EB3BE331C2443ADED45E3A4082412DD876E9 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6));
	const Il2CppFullySharedGenericAny L_0 = alloca(SizeOf_T_t2650EB3BE331C2443ADED45E3A4082412DD876E9);
	const Il2CppFullySharedGenericAny L_2 = alloca(SizeOf_T_t2650EB3BE331C2443ADED45E3A4082412DD876E9);
	Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* V_0 = NULL;
	{
		il2cpp_codegen_memcpy(L_0, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6)) ? ___0_argument : &___0_argument), SizeOf_T_t2650EB3BE331C2443ADED45E3A4082412DD876E9);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_1 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		Result__ctor_mD5334A91B372F17CC957E2376D067FD29F493A72(L_1, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6)) ? il2cpp_codegen_memcpy(L_2, L_0, SizeOf_T_t2650EB3BE331C2443ADED45E3A4082412DD876E9): *(void**)L_0), il2cpp_rgctx_method(method->klass->rgctx_data, 7));
		V_0 = L_1;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93** L_3 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93**)(&__this->___currentResult);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_4 = V_0;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_5;
		L_5 = InterlockedCompareExchangeImpl<Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*>(L_3, L_4, (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)NULL);
		if (!L_5)
		{
			goto IL_0018;
		}
	}
	{
		return (bool)0;
	}

IL_0018:
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_6 = __this->___completion;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_7 = V_0;
		NullCheck(L_6);
		bool L_8;
		L_8 = TaskCompletionSource_1_TrySetResult_m6421F3166CAE62DBE3D5B5C203F0399644E004A1(L_6, L_7, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
		return L_8;
	}
}
// Method Definition Index: 62147
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WebCompletionSource_1_TrySetCompleted_m3569793D667717DAE788FBC010D43FFCF5CC0597_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, const RuntimeMethod* method) 
{
	Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* V_0 = NULL;
	{
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_0 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		Result__ctor_mA920B8E0BECD7D1B6C8AC11BEB43AD07864DB8F8(L_0, (int32_t)1, (ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757*)NULL, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		V_0 = L_0;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93** L_1 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93**)(&__this->___currentResult);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_2 = V_0;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_3;
		L_3 = InterlockedCompareExchangeImpl<Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*>(L_1, L_2, (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)NULL);
		if (!L_3)
		{
			goto IL_0019;
		}
	}
	{
		return (bool)0;
	}

IL_0019:
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_4 = __this->___completion;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_5 = V_0;
		NullCheck(L_4);
		bool L_6;
		L_6 = TaskCompletionSource_1_TrySetResult_m6421F3166CAE62DBE3D5B5C203F0399644E004A1(L_4, L_5, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
		return L_6;
	}
}
// Method Definition Index: 62148
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WebCompletionSource_1_TrySetCanceled_m9E2CFCAC2261552ADC05BF4708D2F70A2DB7B280_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662* L_0 = (OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662*)il2cpp_codegen_object_new(OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662_il2cpp_TypeInfo_var);
		OperationCanceledException__ctor_m2F34C3B8AEE2AA6C7EB2BB77AE5E0289101293E4(L_0, NULL);
		bool L_1;
		L_1 = WebCompletionSource_1_TrySetCanceled_m6069824D799921F76E03A0EED077F2E8B7090826(__this, L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 12));
		return L_1;
	}
}
// Method Definition Index: 62149
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WebCompletionSource_1_TrySetCanceled_m6069824D799921F76E03A0EED077F2E8B7090826_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662* ___0_error, const RuntimeMethod* method) 
{
	Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* V_0 = NULL;
	{
		OperationCanceledException_tC97D0B4532C15E6F0E9F9375091C9ECCA438D662* L_0 = ___0_error;
		ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* L_1;
		L_1 = ExceptionDispatchInfo_Capture_mC1C1C30D83DC04B2B7813DFCB67D07CCD4909803((Exception_t*)L_0, NULL);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_2 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		Result__ctor_mA920B8E0BECD7D1B6C8AC11BEB43AD07864DB8F8(L_2, (int32_t)2, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		V_0 = L_2;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93** L_3 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93**)(&__this->___currentResult);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_4 = V_0;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_5;
		L_5 = InterlockedCompareExchangeImpl<Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*>(L_3, L_4, (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)NULL);
		if (!L_5)
		{
			goto IL_001e;
		}
	}
	{
		return (bool)0;
	}

IL_001e:
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_6 = __this->___completion;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_7 = V_0;
		NullCheck(L_6);
		bool L_8;
		L_8 = TaskCompletionSource_1_TrySetResult_m6421F3166CAE62DBE3D5B5C203F0399644E004A1(L_6, L_7, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
		return L_8;
	}
}
// Method Definition Index: 62150
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WebCompletionSource_1_TrySetException_m0A5AB73E23E85CAD2080073F1380B6AA4B208BCB_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, Exception_t* ___0_error, const RuntimeMethod* method) 
{
	Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* V_0 = NULL;
	{
		Exception_t* L_0 = ___0_error;
		ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* L_1;
		L_1 = ExceptionDispatchInfo_Capture_mC1C1C30D83DC04B2B7813DFCB67D07CCD4909803(L_0, NULL);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_2 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		Result__ctor_mA920B8E0BECD7D1B6C8AC11BEB43AD07864DB8F8(L_2, (int32_t)3, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		V_0 = L_2;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93** L_3 = (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93**)(&__this->___currentResult);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_4 = V_0;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_5;
		L_5 = InterlockedCompareExchangeImpl<Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*>(L_3, L_4, (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93*)NULL);
		if (!L_5)
		{
			goto IL_001e;
		}
	}
	{
		return (bool)0;
	}

IL_001e:
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_6 = __this->___completion;
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_7 = V_0;
		NullCheck(L_6);
		bool L_8;
		L_8 = TaskCompletionSource_1_TrySetResult_m6421F3166CAE62DBE3D5B5C203F0399644E004A1(L_6, L_7, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
		return L_8;
	}
}
// Method Definition Index: 62151
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WebCompletionSource_1_ThrowOnError_m7C2B39BD3A1FE60DD5EA8D0B181EAD73DC000470_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, const RuntimeMethod* method) 
{
	ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* G_B4_0 = NULL;
	ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* G_B3_0 = NULL;
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_0 = __this->___completion;
		NullCheck(L_0);
		Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* L_1;
		L_1 = TaskCompletionSource_1_get_Task_m99C4E7D405DA7485360F4554AD219A778BBED3C7_inline(L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 4));
		NullCheck((Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572*)L_1);
		bool L_2;
		L_2 = Task_get_IsCompleted_m942D6D536545EF059089398B19435591561BB831((Task_t751C4CC3ECD055BABA8A0B6A5DFBB4283DCA8572*)L_1, NULL);
		if (L_2)
		{
			goto IL_0013;
		}
	}
	{
		return;
	}

IL_0013:
	{
		TaskCompletionSource_1_t04C19E28FAF1B686CB256FE9F84AA8AC57A7FEA7* L_3 = __this->___completion;
		NullCheck(L_3);
		Task_1_t82C63013D5AE6BAE3F6A03941A7758CC8CCBC5BC* L_4;
		L_4 = TaskCompletionSource_1_get_Task_m99C4E7D405DA7485360F4554AD219A778BBED3C7_inline(L_3, il2cpp_rgctx_method(method->klass->rgctx_data, 4));
		NullCheck(L_4);
		Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* L_5;
		L_5 = Task_1_get_Result_m4BD43EF8B903D5FEDED967167DB07B2941B7E6C9(L_4, il2cpp_rgctx_method(method->klass->rgctx_data, 13));
		NullCheck(L_5);
		ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* L_6;
		L_6 = Result_get_Error_mA9CAACBF365B2B74E821767A0713ADA11148EC69_inline(L_5, il2cpp_rgctx_method(method->klass->rgctx_data, 14));
		ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* L_7 = L_6;
		if (L_7)
		{
			G_B4_0 = L_7;
			goto IL_002d;
		}
		G_B3_0 = L_7;
	}
	{
		return;
	}

IL_002d:
	{
		NullCheck(G_B4_0);
		ExceptionDispatchInfo_Throw_m06F398E346AE94C1CCEB636763A8CB26511F6330(G_B4_0, NULL);
		return;
	}
}
// Method Definition Index: 62152
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* WebCompletionSource_1_WaitForCompletion_m0A0641169CC3E816311B3D9AAD800FC38CE823FA_gshared (WebCompletionSource_1_t1C9A1856B56A56D2E3CBE124A73CB4ADA3DBAA6F* __this, const RuntimeMethod* method) 
{
	U3CWaitForCompletionU3Ed__15_t1E7A90912CE0FB4BBFDADC017893E65373B96937 V_0;
	memset((&V_0), 0, sizeof(V_0));
	{
		(&V_0)->___U3CU3E4__this = __this;
		Il2CppCodeGenWriteBarrier((void**)(&(&V_0)->___U3CU3E4__this), (void*)__this);
		il2cpp_codegen_runtime_class_init_inline(il2cpp_rgctx_data(method->klass->rgctx_data, 17));
		AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4 L_0;
		L_0 = AsyncTaskMethodBuilder_1_Create_m852C283F3EAD7381A0CC8D14204899C192BDC20A(il2cpp_rgctx_method(method->klass->rgctx_data, 16));
		(&V_0)->___U3CU3Et__builder = L_0;
		Il2CppCodeGenWriteBarrier((void**)&((&(((&(&V_0)->___U3CU3Et__builder))->___m_coreState))->___m_stateMachine), (void*)NULL);
		#if IL2CPP_ENABLE_STRICT_WRITE_BARRIERS
		Il2CppCodeGenWriteBarrier((void**)&((&(((&(&V_0)->___U3CU3Et__builder))->___m_coreState))->___m_defaultContextAction), (void*)NULL);
		#endif
		#if IL2CPP_ENABLE_STRICT_WRITE_BARRIERS
		Il2CppCodeGenWriteBarrier((void**)&(((&(&V_0)->___U3CU3Et__builder))->___m_task), (void*)NULL);
		#endif
		(&V_0)->___U3CU3E1__state = (-1);
		AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4* L_1 = (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4*)(&(&V_0)->___U3CU3Et__builder);
		AsyncTaskMethodBuilder_1_Start_TisU3CWaitForCompletionU3Ed__15_t1E7A90912CE0FB4BBFDADC017893E65373B96937_m38C56B931D2323D0F0219A4AFDBC6416FA04D52A(L_1, (&V_0), il2cpp_rgctx_method(method->klass->rgctx_data, 19));
		AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4* L_2 = (AsyncTaskMethodBuilder_1_t9A3ADCFF6503F4230FFD38F6C333EBCF1A034AF4*)(&(&V_0)->___U3CU3Et__builder);
		Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* L_3;
		L_3 = AsyncTaskMethodBuilder_1_get_Task_m90B072626CA4BF0F567616D4A035739B97F46D8B(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 21));
		return L_3;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 36943
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Where__ctor_m1005F36B2810D6C9BAEA784E3978689A96EB7347_gshared (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C* __this, WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* ___0_observable, RuntimeObject* ___1_observer, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:26>
		Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2((RuntimeObject*)__this, NULL);
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:28>
		WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* L_0 = ___0_observable;
		__this->___m_Observable = L_0;
		Il2CppCodeGenWriteBarrier((void**)(&__this->___m_Observable), (void*)L_0);
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:29>
		RuntimeObject* L_1 = ___1_observer;
		__this->___m_Observer = L_1;
		Il2CppCodeGenWriteBarrier((void**)(&__this->___m_Observer), (void*)L_1);
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:30>
		return;
	}
}
// Method Definition Index: 36944
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Where_OnCompleted_m616C74C91F79C9E2AC50707A678EB9E1FE72EB1C_gshared (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:34>
		return;
	}
}
// Method Definition Index: 36945
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Where_OnError_m856337670C3AEAE4C7F09DA64E3328FF8834431A_gshared (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C* __this, Exception_t* ___0_error, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Debug_t8394C7EEAECA3689C2C9B9DE9C7166D73596276F_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:38>
		Exception_t* L_0 = ___0_error;
		il2cpp_codegen_runtime_class_init_inline(Debug_t8394C7EEAECA3689C2C9B9DE9C7166D73596276F_il2cpp_TypeInfo_var);
		Debug_LogException_mAB3F4DC7297ED8FBB49DAA718B70E59A6B0171B0(L_0, NULL);
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:39>
		return;
	}
}
// Method Definition Index: 36946
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void Where_OnNext_mA0CF021050C0C4674B3F473DB08E0A7F15D8DEF3_gshared (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C* __this, Il2CppFullySharedGenericAny ___0_evt, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t646830852B65DBDC12DCC4F9FEFADE171F489ABE = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4));
	const Il2CppFullySharedGenericAny L_2 = alloca(SizeOf_TValue_t646830852B65DBDC12DCC4F9FEFADE171F489ABE);
	const Il2CppFullySharedGenericAny L_5 = L_2;
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:43>
		WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* L_0 = __this->___m_Observable;
		NullCheck(L_0);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = L_0->___m_Predicate;
		il2cpp_codegen_memcpy(L_2, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4)) ? ___0_evt : &___0_evt), SizeOf_TValue_t646830852B65DBDC12DCC4F9FEFADE171F489ABE);
		NullCheck(L_1);
		bool L_3;
		L_3 = Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline(L_1, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4)) ? L_2: *(void**)L_2), il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		if (!L_3)
		{
			goto IL_001f;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:44>
		RuntimeObject* L_4 = __this->___m_Observer;
		il2cpp_codegen_memcpy(L_5, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4)) ? ___0_evt : &___0_evt), SizeOf_TValue_t646830852B65DBDC12DCC4F9FEFADE171F489ABE);
		NullCheck(L_4);
		InterfaceActionInvoker1Invoker< Il2CppFullySharedGenericAny >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 2), L_4, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4)) ? L_5: *(void**)L_5));
	}

IL_001f:
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:45>
		return;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 89176
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereArrayIterator_1__ctor_mD8BDE04F9897AAED299EE4DC32BF3879F2CBB668_gshared (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method) 
{
	{
		Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 0));
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = ___0_source;
		il2cpp_codegen_write_instance_field_data<__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0), L_0);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = ___1_predicate;
		il2cpp_codegen_write_instance_field_data<Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1), L_1);
		return;
	}
}
// Method Definition Index: 89177
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* WhereArrayIterator_1_Clone_m1D80001794E47D2DF00A77273FD71D61987E8A44_gshared (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* __this, const RuntimeMethod* method) 
{
	{
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = *(__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* L_2 = (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereArrayIterator_1__ctor_mD8BDE04F9897AAED299EE4DC32BF3879F2CBB668(L_2, L_0, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		return (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)L_2;
	}
}
// Method Definition Index: 89178
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WhereArrayIterator_1_MoveNext_m42FC055181A1CDD12BBB46A9EE9ED76C6048BA07_gshared (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* __this, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7));
	const Il2CppFullySharedGenericAny L_4 = alloca(SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
	const Il2CppFullySharedGenericAny L_9 = L_4;
	const Il2CppFullySharedGenericAny L_7 = alloca(SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
	Il2CppFullySharedGenericAny V_0 = alloca(SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
	memset(V_0, 0, SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
	{
		int32_t L_0 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),1));
		if ((!(((uint32_t)L_0) == ((uint32_t)1))))
		{
			goto IL_0058;
		}
	}
	{
		goto IL_0042;
	}

IL_000b:
	{
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_1 = *(__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		int32_t L_2 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		NullCheck(L_1);
		int32_t L_3 = L_2;
		il2cpp_codegen_memcpy(L_4, (L_1)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_3)), SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
		il2cpp_codegen_memcpy(V_0, L_4, SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
		int32_t L_5 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		il2cpp_codegen_write_instance_field_data<int32_t>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2), ((int32_t)il2cpp_codegen_add(L_5, 1)));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_6 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		il2cpp_codegen_memcpy(L_7, V_0, SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
		NullCheck(L_6);
		bool L_8;
		L_8 = Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline(L_6, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7)) ? L_7: *(void**)L_7), il2cpp_rgctx_method(method->klass->rgctx_data, 8));
		if (!L_8)
		{
			goto IL_0042;
		}
	}
	{
		il2cpp_codegen_memcpy(L_9, V_0, SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),2), L_9, SizeOf_TSource_tA44A3A99F6F77148305A3C32D2C4DE1D4226338A);
		return (bool)1;
	}

IL_0042:
	{
		int32_t L_10 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_11 = *(__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		NullCheck(L_11);
		if ((((int32_t)L_10) < ((int32_t)((int32_t)(((RuntimeArray*)L_11)->max_length)))))
		{
			goto IL_000b;
		}
	}
	{
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		VirtualActionInvoker0::Invoke(12, (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
	}

IL_0058:
	{
		return (bool)0;
	}
}
// Method Definition Index: 89180
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* WhereArrayIterator_1_Where_mB2C59E78355E518D359A6D5035BCD6254337B84E_gshared (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* __this, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate, const RuntimeMethod* method) 
{
	{
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = *(__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_2 = ___0_predicate;
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_3;
		L_3 = Enumerable_CombinePredicates_TisIl2CppFullySharedGenericAny_m93E135AF98923DA7992DF8B462586C255923A45D(L_1, L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6* L_4 = (WhereArrayIterator_1_tA7187088CE8DF4724576F6B7F633203C144505F6*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereArrayIterator_1__ctor_mD8BDE04F9897AAED299EE4DC32BF3879F2CBB668(L_4, L_0, L_3, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		return (RuntimeObject*)L_4;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 89170
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6_gshared (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* __this, RuntimeObject* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method) 
{
	{
		Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 0));
		RuntimeObject* L_0 = ___0_source;
		il2cpp_codegen_write_instance_field_data<RuntimeObject*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0), L_0);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = ___1_predicate;
		il2cpp_codegen_write_instance_field_data<Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1), L_1);
		return;
	}
}
// Method Definition Index: 89171
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* WhereEnumerableIterator_1_Clone_m0317D203B88386A9A479C72FA9D62763FD0A91D3_gshared (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* __this, const RuntimeMethod* method) 
{
	{
		RuntimeObject* L_0 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* L_2 = (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6(L_2, L_0, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		return (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)L_2;
	}
}
// Method Definition Index: 89172
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereEnumerableIterator_1_Dispose_m2583FECFDC8EDFE66C959C7C386F99E287C5763E_gshared (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&IDisposable_t030E0496B4E0E4E4F086825007979AF51F7248C5_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		RuntimeObject* L_0 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		if (!L_0)
		{
			goto IL_0013;
		}
	}
	{
		RuntimeObject* L_1 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		NullCheck((RuntimeObject*)L_1);
		InterfaceActionInvoker0::Invoke(0, IDisposable_t030E0496B4E0E4E4F086825007979AF51F7248C5_il2cpp_TypeInfo_var, (RuntimeObject*)L_1);
	}

IL_0013:
	{
		il2cpp_codegen_write_instance_field_data<RuntimeObject*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2), (RuntimeObject*)NULL);
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		Iterator_1_Dispose_m4BA67A3D7DA249425AA8E0A0EC94AB535444D1AD((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
		return;
	}
}
// Method Definition Index: 89173
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WhereEnumerableIterator_1_MoveNext_m1A18D4050C069B6C4310DAB9857281E37DCB2C69_gshared (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&IEnumerator_t7B609C2FFA6EB5167D9C62A0C32A21DE2F666DAA_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	const uint32_t SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 11));
	const Il2CppFullySharedGenericAny L_6 = alloca(SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
	const Il2CppFullySharedGenericAny L_10 = L_6;
	const Il2CppFullySharedGenericAny L_8 = alloca(SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
	int32_t V_0 = 0;
	Il2CppFullySharedGenericAny V_1 = alloca(SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
	memset(V_1, 0, SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
	{
		int32_t L_0 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),1));
		V_0 = L_0;
		int32_t L_1 = V_0;
		if ((((int32_t)L_1) == ((int32_t)1)))
		{
			goto IL_0011;
		}
	}
	{
		int32_t L_2 = V_0;
		if ((((int32_t)L_2) == ((int32_t)2)))
		{
			goto IL_004e;
		}
	}
	{
		goto IL_0061;
	}

IL_0011:
	{
		RuntimeObject* L_3 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		NullCheck(L_3);
		RuntimeObject* L_4;
		L_4 = InterfaceFuncInvoker0< RuntimeObject* >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 2), L_3);
		il2cpp_codegen_write_instance_field_data<RuntimeObject*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2), L_4);
		il2cpp_codegen_write_instance_field_data<int32_t>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),1), 2);
		goto IL_004e;
	}

IL_002b:
	{
		RuntimeObject* L_5 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		NullCheck(L_5);
		InterfaceActionInvoker1Invoker< Il2CppFullySharedGenericAny* >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 7), L_5, (Il2CppFullySharedGenericAny*)L_6);
		il2cpp_codegen_memcpy(V_1, L_6, SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_7 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		il2cpp_codegen_memcpy(L_8, V_1, SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
		NullCheck(L_7);
		bool L_9;
		L_9 = Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline(L_7, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 11)) ? L_8: *(void**)L_8), il2cpp_rgctx_method(method->klass->rgctx_data, 12));
		if (!L_9)
		{
			goto IL_004e;
		}
	}
	{
		il2cpp_codegen_memcpy(L_10, V_1, SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),2), L_10, SizeOf_TSource_tC0EDCBB06D927E5200EDA4B413FCECB2FDD7AFEB);
		return (bool)1;
	}

IL_004e:
	{
		RuntimeObject* L_11 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		NullCheck((RuntimeObject*)L_11);
		bool L_12;
		L_12 = InterfaceFuncInvoker0< bool >::Invoke(0, IEnumerator_t7B609C2FFA6EB5167D9C62A0C32A21DE2F666DAA_il2cpp_TypeInfo_var, (RuntimeObject*)L_11);
		if (L_12)
		{
			goto IL_002b;
		}
	}
	{
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		VirtualActionInvoker0::Invoke(12, (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
	}

IL_0061:
	{
		return (bool)0;
	}
}
// Method Definition Index: 89175
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* WhereEnumerableIterator_1_Where_mC623267514B4299E409A01161DBBDA5362CEDFC2_gshared (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* __this, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate, const RuntimeMethod* method) 
{
	{
		RuntimeObject* L_0 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_2 = ___0_predicate;
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_3;
		L_3 = Enumerable_CombinePredicates_TisIl2CppFullySharedGenericAny_m93E135AF98923DA7992DF8B462586C255923A45D(L_1, L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 13));
		WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* L_4 = (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6(L_4, L_0, L_3, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		return (RuntimeObject*)L_4;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 89181
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereListIterator_1__ctor_mC075454926AF320E4679335A1B81D3F56ACEFC0C_gshared (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* __this, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method) 
{
	{
		Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 0));
		List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* L_0 = ___0_source;
		il2cpp_codegen_write_instance_field_data<List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0), L_0);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = ___1_predicate;
		il2cpp_codegen_write_instance_field_data<Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1), L_1);
		return;
	}
}
// Method Definition Index: 89182
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* WhereListIterator_1_Clone_mAA3ED56493E5FF2F49FE37EB7CDF6C0A957698B5_gshared (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* __this, const RuntimeMethod* method) 
{
	{
		List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* L_0 = *(List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* L_2 = (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereListIterator_1__ctor_mC075454926AF320E4679335A1B81D3F56ACEFC0C(L_2, L_0, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		return (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)L_2;
	}
}
// Method Definition Index: 89183
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WhereListIterator_1_MoveNext_mB5E4EB089AD8CF7156B8972C7FB61739C466ED5E_gshared (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* __this, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 11));
	const uint32_t SizeOf_Enumerator_t8E62FE91E95BFC5D28A3B09EFA69C2A33120205E = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 8));
	const Il2CppFullySharedGenericAny L_5 = alloca(SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
	const Il2CppFullySharedGenericAny L_9 = L_5;
	const Il2CppFullySharedGenericAny L_7 = alloca(SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
	const Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF L_4 = alloca(SizeOf_Enumerator_t8E62FE91E95BFC5D28A3B09EFA69C2A33120205E);
	int32_t V_0 = 0;
	Il2CppFullySharedGenericAny V_1 = alloca(SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
	memset(V_1, 0, SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
	{
		int32_t L_0 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),1));
		V_0 = L_0;
		int32_t L_1 = V_0;
		if ((((int32_t)L_1) == ((int32_t)1)))
		{
			goto IL_0011;
		}
	}
	{
		int32_t L_2 = V_0;
		if ((((int32_t)L_2) == ((int32_t)2)))
		{
			goto IL_004e;
		}
	}
	{
		goto IL_0061;
	}

IL_0011:
	{
		List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* L_3 = *(List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		NullCheck(L_3);
		List_1_GetEnumerator_m8B2A92ACD4FBA5FBDC3F6F4F5C23A0DDF491DA61(L_3, (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*)L_4, il2cpp_rgctx_method(method->klass->rgctx_data, 7));
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2), L_4, SizeOf_Enumerator_t8E62FE91E95BFC5D28A3B09EFA69C2A33120205E);
		il2cpp_codegen_write_instance_field_data<int32_t>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),1), 2);
		goto IL_004e;
	}

IL_002b:
	{
		Enumerator_get_Current_m8B42D4B2DE853B9D11B997120CD0228D4780E394_inline((((Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2)))), (Il2CppFullySharedGenericAny*)L_5, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
		il2cpp_codegen_memcpy(V_1, L_5, SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_6 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		il2cpp_codegen_memcpy(L_7, V_1, SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
		NullCheck(L_6);
		bool L_8;
		L_8 = Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline(L_6, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 11)) ? L_7: *(void**)L_7), il2cpp_rgctx_method(method->klass->rgctx_data, 12));
		if (!L_8)
		{
			goto IL_004e;
		}
	}
	{
		il2cpp_codegen_memcpy(L_9, V_1, SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6),2), L_9, SizeOf_TSource_t85B7C93A555823AE666813BFFC5FEC432E108956);
		return (bool)1;
	}

IL_004e:
	{
		bool L_10;
		L_10 = Enumerator_MoveNext_m8D8E5E878AF0A88A535AB1AB5BA4F23E151A678A((((Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2)))), il2cpp_rgctx_method(method->klass->rgctx_data, 13));
		if (L_10)
		{
			goto IL_002b;
		}
	}
	{
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		VirtualActionInvoker0::Invoke(12, (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
	}

IL_0061:
	{
		return (bool)0;
	}
}
// Method Definition Index: 89185
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* WhereListIterator_1_Where_mC767815DE2249E70B38D6D172A0C61B028D7A44B_gshared (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* __this, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate, const RuntimeMethod* method) 
{
	{
		List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* L_0 = *(List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_2 = ___0_predicate;
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_3;
		L_3 = Enumerable_CombinePredicates_TisIl2CppFullySharedGenericAny_m93E135AF98923DA7992DF8B462586C255923A45D(L_1, L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 15));
		WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0* L_4 = (WhereListIterator_1_tD37742ECD2F53395BA8B668C2671C4C82E8E85F0*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereListIterator_1__ctor_mC075454926AF320E4679335A1B81D3F56ACEFC0C(L_4, L_0, L_3, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		return (RuntimeObject*)L_4;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 36941
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereObservable_1__ctor_m6C7B01F3F1790F57E8A6CB4AA4B3C3FF98902286_gshared (WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* __this, RuntimeObject* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:10>
		Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2((RuntimeObject*)__this, NULL);
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:12>
		RuntimeObject* L_0 = ___0_source;
		__this->___m_Source = L_0;
		Il2CppCodeGenWriteBarrier((void**)(&__this->___m_Source), (void*)L_0);
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:13>
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = ___1_predicate;
		__this->___m_Predicate = L_1;
		Il2CppCodeGenWriteBarrier((void**)(&__this->___m_Predicate), (void*)L_1);
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:14>
		return;
	}
}
// Method Definition Index: 36942
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* WhereObservable_1_Subscribe_m168CEC0B9EEA35158738902505C40C2DE2D53ED5_gshared (WhereObservable_1_tEA716A5FC9C57957678BF073F6DD611E500A5816* __this, RuntimeObject* ___0_observer, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.inputsystem@be6c4fd0abf5/InputSystem/Utilities/Observables/WhereObservable.cs:18>
		RuntimeObject* L_0 = __this->___m_Source;
		RuntimeObject* L_1 = ___0_observer;
		Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C* L_2 = (Where_t04DB031F94FE910A83839B12D2DC5BCACAA6F25C*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 4));
		Where__ctor_m1005F36B2810D6C9BAEA784E3978689A96EB7347(L_2, __this, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		NullCheck(L_0);
		RuntimeObject* L_3;
		L_3 = InterfaceFuncInvoker1< RuntimeObject*, RuntimeObject* >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 0), L_0, (RuntimeObject*)L_2);
		return L_3;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 89192
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereSelectArrayIterator_2__ctor_mB15DB27A8DC3B4E00BCA6E8F63F00F7E374F76A4_gshared (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method) 
{
	{
		Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 0));
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = ___0_source;
		il2cpp_codegen_write_instance_field_data<__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0), L_0);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = ___1_predicate;
		il2cpp_codegen_write_instance_field_data<Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1), L_1);
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_2 = ___2_selector;
		il2cpp_codegen_write_instance_field_data<Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2), L_2);
		return;
	}
}
// Method Definition Index: 89193
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* WhereSelectArrayIterator_2_Clone_mFBF81AE0E2B6F7A7A79FC98398E7A6AC0FD330E9_gshared (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174* __this, const RuntimeMethod* method) 
{
	{
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = *(__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_2 = *(Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174* L_3 = (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereSelectArrayIterator_2__ctor_mB15DB27A8DC3B4E00BCA6E8F63F00F7E374F76A4(L_3, L_0, L_1, L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 6));
		return (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)L_3;
	}
}
// Method Definition Index: 89194
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WhereSelectArrayIterator_2_MoveNext_mEF7E8E7B117D6D1147C53CAE838836974171392C_gshared (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174* __this, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 8));
	const uint32_t SizeOf_TResult_t278B55150BC17BB45D33B605F011F4D96EFE5425 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 11));
	const Il2CppFullySharedGenericAny L_4 = alloca(SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78);
	const Il2CppFullySharedGenericAny L_8 = L_4;
	const Il2CppFullySharedGenericAny L_11 = L_4;
	const Il2CppFullySharedGenericAny L_12 = alloca(SizeOf_TResult_t278B55150BC17BB45D33B605F011F4D96EFE5425);
	Il2CppFullySharedGenericAny V_0 = alloca(SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78);
	memset(V_0, 0, SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78);
	{
		int32_t L_0 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),1));
		if ((!(((uint32_t)L_0) == ((uint32_t)1))))
		{
			goto IL_006b;
		}
	}
	{
		goto IL_0055;
	}

IL_000b:
	{
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_1 = *(__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		int32_t L_2 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3));
		NullCheck(L_1);
		int32_t L_3 = L_2;
		il2cpp_codegen_memcpy(L_4, (L_1)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_3)), SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78);
		il2cpp_codegen_memcpy(V_0, L_4, SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78);
		int32_t L_5 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3));
		il2cpp_codegen_write_instance_field_data<int32_t>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3), ((int32_t)il2cpp_codegen_add(L_5, 1)));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_6 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		if (!L_6)
		{
			goto IL_0041;
		}
	}
	{
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_7 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		il2cpp_codegen_memcpy(L_8, V_0, SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78);
		NullCheck(L_7);
		bool L_9;
		L_9 = Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline(L_7, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 8)) ? L_8: *(void**)L_8), il2cpp_rgctx_method(method->klass->rgctx_data, 9));
		if (!L_9)
		{
			goto IL_0055;
		}
	}

IL_0041:
	{
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_10 = *(Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		il2cpp_codegen_memcpy(L_11, V_0, SizeOf_TSource_t21BF09076F270DC063711DE3ABB52B001A331F78);
		NullCheck(L_10);
		Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_inline(L_10, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 8)) ? L_11: *(void**)L_11), (Il2CppFullySharedGenericAny*)L_12, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),2), L_12, SizeOf_TResult_t278B55150BC17BB45D33B605F011F4D96EFE5425);
		return (bool)1;
	}

IL_0055:
	{
		int32_t L_13 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3));
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_14 = *(__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		NullCheck(L_14);
		if ((((int32_t)L_13) < ((int32_t)((int32_t)(((RuntimeArray*)L_14)->max_length)))))
		{
			goto IL_000b;
		}
	}
	{
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		VirtualActionInvoker0::Invoke(12, (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
	}

IL_006b:
	{
		return (bool)0;
	}
}
// Method Definition Index: 89196
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* WhereSelectArrayIterator_2_Where_mD81DB59B1D07BC8DDB099A652B22BA9C1538D7A3_gshared (WhereSelectArrayIterator_2_tBE026CE497BB8F36E31685722BBD7CB567570174* __this, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate, const RuntimeMethod* method) 
{
	{
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_0 = ___0_predicate;
		WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* L_1 = (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 14));
		WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6(L_1, (RuntimeObject*)__this, L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 15));
		return (RuntimeObject*)L_1;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 89186
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereSelectEnumerableIterator_2__ctor_m9A4AF54DC527FA1CEF8B803C8DDA5E632838B06F_gshared (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* __this, RuntimeObject* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method) 
{
	{
		Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 0));
		RuntimeObject* L_0 = ___0_source;
		il2cpp_codegen_write_instance_field_data<RuntimeObject*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0), L_0);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = ___1_predicate;
		il2cpp_codegen_write_instance_field_data<Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1), L_1);
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_2 = ___2_selector;
		il2cpp_codegen_write_instance_field_data<Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2), L_2);
		return;
	}
}
// Method Definition Index: 89187
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* WhereSelectEnumerableIterator_2_Clone_mD773B8B24D1459B11BA4462A6DD68865514ADC9E_gshared (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* __this, const RuntimeMethod* method) 
{
	{
		RuntimeObject* L_0 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_2 = *(Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* L_3 = (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereSelectEnumerableIterator_2__ctor_m9A4AF54DC527FA1CEF8B803C8DDA5E632838B06F(L_3, L_0, L_1, L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 6));
		return (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)L_3;
	}
}
// Method Definition Index: 89188
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereSelectEnumerableIterator_2_Dispose_m640FAC111BC786414B40480BB03E4F84B2FFB179_gshared (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&IDisposable_t030E0496B4E0E4E4F086825007979AF51F7248C5_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		RuntimeObject* L_0 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3));
		if (!L_0)
		{
			goto IL_0013;
		}
	}
	{
		RuntimeObject* L_1 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3));
		NullCheck((RuntimeObject*)L_1);
		InterfaceActionInvoker0::Invoke(0, IDisposable_t030E0496B4E0E4E4F086825007979AF51F7248C5_il2cpp_TypeInfo_var, (RuntimeObject*)L_1);
	}

IL_0013:
	{
		il2cpp_codegen_write_instance_field_data<RuntimeObject*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3), (RuntimeObject*)NULL);
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		Iterator_1_Dispose_m4BA67A3D7DA249425AA8E0A0EC94AB535444D1AD((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
		return;
	}
}
// Method Definition Index: 89189
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WhereSelectEnumerableIterator_2_MoveNext_mB384EFAF6366166F28EDFDBA272EEC1089E1A115_gshared (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&IEnumerator_t7B609C2FFA6EB5167D9C62A0C32A21DE2F666DAA_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	const uint32_t SizeOf_TSource_t5B0D27614F68D07DB050466831DEDC1DDEFFC093 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 12));
	const uint32_t SizeOf_TResult_t33CDF94D13BEBA6908E84F958D63A95F7466E520 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 15));
	const Il2CppFullySharedGenericAny L_6 = alloca(SizeOf_TSource_t5B0D27614F68D07DB050466831DEDC1DDEFFC093);
	const Il2CppFullySharedGenericAny L_9 = L_6;
	const Il2CppFullySharedGenericAny L_12 = L_6;
	const Il2CppFullySharedGenericAny L_13 = alloca(SizeOf_TResult_t33CDF94D13BEBA6908E84F958D63A95F7466E520);
	int32_t V_0 = 0;
	Il2CppFullySharedGenericAny V_1 = alloca(SizeOf_TSource_t5B0D27614F68D07DB050466831DEDC1DDEFFC093);
	memset(V_1, 0, SizeOf_TSource_t5B0D27614F68D07DB050466831DEDC1DDEFFC093);
	{
		int32_t L_0 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),1));
		V_0 = L_0;
		int32_t L_1 = V_0;
		if ((((int32_t)L_1) == ((int32_t)1)))
		{
			goto IL_0011;
		}
	}
	{
		int32_t L_2 = V_0;
		if ((((int32_t)L_2) == ((int32_t)2)))
		{
			goto IL_0061;
		}
	}
	{
		goto IL_0074;
	}

IL_0011:
	{
		RuntimeObject* L_3 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		NullCheck(L_3);
		RuntimeObject* L_4;
		L_4 = InterfaceFuncInvoker0< RuntimeObject* >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 2), L_3);
		il2cpp_codegen_write_instance_field_data<RuntimeObject*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3), L_4);
		il2cpp_codegen_write_instance_field_data<int32_t>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),1), 2);
		goto IL_0061;
	}

IL_002b:
	{
		RuntimeObject* L_5 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3));
		NullCheck(L_5);
		InterfaceActionInvoker1Invoker< Il2CppFullySharedGenericAny* >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 8), L_5, (Il2CppFullySharedGenericAny*)L_6);
		il2cpp_codegen_memcpy(V_1, L_6, SizeOf_TSource_t5B0D27614F68D07DB050466831DEDC1DDEFFC093);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_7 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		if (!L_7)
		{
			goto IL_004d;
		}
	}
	{
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_8 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		il2cpp_codegen_memcpy(L_9, V_1, SizeOf_TSource_t5B0D27614F68D07DB050466831DEDC1DDEFFC093);
		NullCheck(L_8);
		bool L_10;
		L_10 = Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline(L_8, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 12)) ? L_9: *(void**)L_9), il2cpp_rgctx_method(method->klass->rgctx_data, 13));
		if (!L_10)
		{
			goto IL_0061;
		}
	}

IL_004d:
	{
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_11 = *(Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		il2cpp_codegen_memcpy(L_12, V_1, SizeOf_TSource_t5B0D27614F68D07DB050466831DEDC1DDEFFC093);
		NullCheck(L_11);
		Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_inline(L_11, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 12)) ? L_12: *(void**)L_12), (Il2CppFullySharedGenericAny*)L_13, il2cpp_rgctx_method(method->klass->rgctx_data, 14));
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),2), L_13, SizeOf_TResult_t33CDF94D13BEBA6908E84F958D63A95F7466E520);
		return (bool)1;
	}

IL_0061:
	{
		RuntimeObject* L_14 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3));
		NullCheck((RuntimeObject*)L_14);
		bool L_15;
		L_15 = InterfaceFuncInvoker0< bool >::Invoke(0, IEnumerator_t7B609C2FFA6EB5167D9C62A0C32A21DE2F666DAA_il2cpp_TypeInfo_var, (RuntimeObject*)L_14);
		if (L_15)
		{
			goto IL_002b;
		}
	}
	{
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		VirtualActionInvoker0::Invoke(12, (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
	}

IL_0074:
	{
		return (bool)0;
	}
}
// Method Definition Index: 89191
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* WhereSelectEnumerableIterator_2_Where_mB8ACBBFA48460E67B18647EF16E6EE4D0BE08679_gshared (WhereSelectEnumerableIterator_2_t1FBA58379B31F544881FB4C45B2D102F32A71E1C* __this, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate, const RuntimeMethod* method) 
{
	{
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_0 = ___0_predicate;
		WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* L_1 = (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 17));
		WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6(L_1, (RuntimeObject*)__this, L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 18));
		return (RuntimeObject*)L_1;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 89197
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WhereSelectListIterator_2__ctor_m6BFCBB5460270ED1896D24DC7E3B83F4950D2140_gshared (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336* __this, List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* ___0_source, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___1_predicate, Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* ___2_selector, const RuntimeMethod* method) 
{
	{
		Iterator_1__ctor_m0EADA9A3982A5CA2DF574359A549E11818802F2A((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this, il2cpp_rgctx_method(method->klass->rgctx_data, 0));
		List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* L_0 = ___0_source;
		il2cpp_codegen_write_instance_field_data<List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0), L_0);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = ___1_predicate;
		il2cpp_codegen_write_instance_field_data<Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1), L_1);
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_2 = ___2_selector;
		il2cpp_codegen_write_instance_field_data<Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2), L_2);
		return;
	}
}
// Method Definition Index: 89198
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0* WhereSelectListIterator_2_Clone_m8EC8E684FFDC3BC579DF37C08993B7F80966639D_gshared (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336* __this, const RuntimeMethod* method) 
{
	{
		List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* L_0 = *(List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_1 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_2 = *(Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336* L_3 = (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		WhereSelectListIterator_2__ctor_m6BFCBB5460270ED1896D24DC7E3B83F4950D2140(L_3, L_0, L_1, L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 6));
		return (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)L_3;
	}
}
// Method Definition Index: 89199
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool WhereSelectListIterator_2_MoveNext_mBB81EEF5DFFEBDDB1AC24116FAD1D13505525569_gshared (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336* __this, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TSource_tEB7490DB2885922B8C60E28873F5DB811BD9CEB3 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 12));
	const uint32_t SizeOf_Enumerator_t8A622325AF1352D3AB0ECDBB45A0AFB7AF959716 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 9));
	const uint32_t SizeOf_TResult_t11AC9139084FDCB528CAF75FE5166467D3329A05 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 15));
	const Il2CppFullySharedGenericAny L_5 = alloca(SizeOf_TSource_tEB7490DB2885922B8C60E28873F5DB811BD9CEB3);
	const Il2CppFullySharedGenericAny L_8 = L_5;
	const Il2CppFullySharedGenericAny L_11 = L_5;
	const Il2CppFullySharedGenericAny L_12 = alloca(SizeOf_TResult_t11AC9139084FDCB528CAF75FE5166467D3329A05);
	const Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF L_4 = alloca(SizeOf_Enumerator_t8A622325AF1352D3AB0ECDBB45A0AFB7AF959716);
	int32_t V_0 = 0;
	Il2CppFullySharedGenericAny V_1 = alloca(SizeOf_TSource_tEB7490DB2885922B8C60E28873F5DB811BD9CEB3);
	memset(V_1, 0, SizeOf_TSource_tEB7490DB2885922B8C60E28873F5DB811BD9CEB3);
	{
		int32_t L_0 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),1));
		V_0 = L_0;
		int32_t L_1 = V_0;
		if ((((int32_t)L_1) == ((int32_t)1)))
		{
			goto IL_0011;
		}
	}
	{
		int32_t L_2 = V_0;
		if ((((int32_t)L_2) == ((int32_t)2)))
		{
			goto IL_0061;
		}
	}
	{
		goto IL_0074;
	}

IL_0011:
	{
		List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A* L_3 = *(List_1_tDBA89B0E21BAC58CFBD3C1F76E4668E3B562761A**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),0));
		NullCheck(L_3);
		List_1_GetEnumerator_m8B2A92ACD4FBA5FBDC3F6F4F5C23A0DDF491DA61(L_3, (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*)L_4, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3), L_4, SizeOf_Enumerator_t8A622325AF1352D3AB0ECDBB45A0AFB7AF959716);
		il2cpp_codegen_write_instance_field_data<int32_t>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),1), 2);
		goto IL_0061;
	}

IL_002b:
	{
		Enumerator_get_Current_m8B42D4B2DE853B9D11B997120CD0228D4780E394_inline((((Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3)))), (Il2CppFullySharedGenericAny*)L_5, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		il2cpp_codegen_memcpy(V_1, L_5, SizeOf_TSource_tEB7490DB2885922B8C60E28873F5DB811BD9CEB3);
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_6 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		if (!L_6)
		{
			goto IL_004d;
		}
	}
	{
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_7 = *(Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),1));
		il2cpp_codegen_memcpy(L_8, V_1, SizeOf_TSource_tEB7490DB2885922B8C60E28873F5DB811BD9CEB3);
		NullCheck(L_7);
		bool L_9;
		L_9 = Func_2_Invoke_mFF6CAE6DFB13AFB5921FB3201467228A326875DE_inline(L_7, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 12)) ? L_8: *(void**)L_8), il2cpp_rgctx_method(method->klass->rgctx_data, 13));
		if (!L_9)
		{
			goto IL_0061;
		}
	}

IL_004d:
	{
		Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* L_10 = *(Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),2));
		il2cpp_codegen_memcpy(L_11, V_1, SizeOf_TSource_tEB7490DB2885922B8C60E28873F5DB811BD9CEB3);
		NullCheck(L_10);
		Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_inline(L_10, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 12)) ? L_11: *(void**)L_11), (Il2CppFullySharedGenericAny*)L_12, il2cpp_rgctx_method(method->klass->rgctx_data, 14));
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 7),2), L_12, SizeOf_TResult_t11AC9139084FDCB528CAF75FE5166467D3329A05);
		return (bool)1;
	}

IL_0061:
	{
		bool L_13;
		L_13 = Enumerator_MoveNext_m8D8E5E878AF0A88A535AB1AB5BA4F23E151A678A((((Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 3),3)))), il2cpp_rgctx_method(method->klass->rgctx_data, 16));
		if (L_13)
		{
			goto IL_002b;
		}
	}
	{
		NullCheck((Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
		VirtualActionInvoker0::Invoke(12, (Iterator_1_t0F1D8198E840368AC82131EC1FF03EB76BCE73B0*)__this);
	}

IL_0074:
	{
		return (bool)0;
	}
}
// Method Definition Index: 89201
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* WhereSelectListIterator_2_Where_m1739BDD134D3AF5A55DBB06AEE130B0C58E47014_gshared (WhereSelectListIterator_2_t86EE6817E8A1706688C6D82D82C9D44BC99CC336* __this, Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* ___0_predicate, const RuntimeMethod* method) 
{
	{
		Func_2_t19E50C11C3E1F20B5A8FDB85D7DD353B6DFF868B* L_0 = ___0_predicate;
		WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B* L_1 = (WhereEnumerableIterator_1_t8B24528558F527941435C4FE1D046216FE4F277B*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 19));
		WhereEnumerableIterator_1__ctor_m2DD2BB86C5517EDD8C051BBF8CE38C43D712A8D6(L_1, (RuntimeObject*)__this, L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 20));
		return (RuntimeObject*)L_1;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 56315
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1__ctor_mFEB81358558CEF0264CCE077535DB880EA2492BA_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcLen, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:108>
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = ___0_src;
		int32_t L_1 = ___1_srcLen;
		WorkSlice_1__ctor_m7AC3CC7AABC83B76D23D2B94329DD4D0200156FA(__this, L_0, 0, L_1, il2cpp_rgctx_method(InitializedTypeInfo(method->klass)->rgctx_data, 1));
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:108>
		return;
	}
}
IL2CPP_EXTERN_C  void WorkSlice_1__ctor_mFEB81358558CEF0264CCE077535DB880EA2492BA_AdjustorThunk (RuntimeObject* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcLen, const RuntimeMethod* method)
{
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*>(__this + _offset);
	WorkSlice_1__ctor_mFEB81358558CEF0264CCE077535DB880EA2492BA(_thisAdjusted, ___0_src, ___1_srcLen, method);
}
// Method Definition Index: 56316
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1__ctor_m7AC3CC7AABC83B76D23D2B94329DD4D0200156FA_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcStart, int32_t ___2_srcLen, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Math_tEB65DE7CA8B083C412C969C92981C030865486CE_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* G_B2_0 = NULL;
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* G_B1_0 = NULL;
	int32_t G_B3_0 = 0;
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* G_B3_1 = NULL;
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:112>
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = ___0_src;
		__this->___m_Data = L_0;
		Il2CppCodeGenWriteBarrier((void**)(&__this->___m_Data), (void*)L_0);
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:113>
		int32_t L_1 = ___1_srcStart;
		__this->___m_Start = L_1;
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:114>
		int32_t L_2 = ___2_srcLen;
		if ((((int32_t)L_2) < ((int32_t)0)))
		{
			G_B2_0 = __this;
			goto IL_001e;
		}
		G_B1_0 = __this;
	}
	{
		int32_t L_3 = ___2_srcLen;
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_4 = ___0_src;
		NullCheck(L_4);
		il2cpp_codegen_runtime_class_init_inline(Math_tEB65DE7CA8B083C412C969C92981C030865486CE_il2cpp_TypeInfo_var);
		int32_t L_5;
		L_5 = Math_Min_m53C488772A34D53917BCA2A491E79A0A5356ED52(L_3, ((int32_t)(((RuntimeArray*)L_4)->max_length)), NULL);
		G_B3_0 = L_5;
		G_B3_1 = G_B1_0;
		goto IL_0021;
	}

IL_001e:
	{
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_6 = ___0_src;
		NullCheck(L_6);
		G_B3_0 = ((int32_t)(((RuntimeArray*)L_6)->max_length));
		G_B3_1 = G_B2_0;
	}

IL_0021:
	{
		G_B3_1->___m_Length = G_B3_0;
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:116>
		return;
	}
}
IL2CPP_EXTERN_C  void WorkSlice_1__ctor_m7AC3CC7AABC83B76D23D2B94329DD4D0200156FA_AdjustorThunk (RuntimeObject* __this, __Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* ___0_src, int32_t ___1_srcStart, int32_t ___2_srcLen, const RuntimeMethod* method)
{
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*>(__this + _offset);
	WorkSlice_1__ctor_m7AC3CC7AABC83B76D23D2B94329DD4D0200156FA(_thisAdjusted, ___0_src, ___1_srcStart, ___2_srcLen, method);
}
// Method Definition Index: 56317
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1_get_Item_mFDEC427E08156ECD6879AD45AEE3618B43E3F726_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, int32_t ___0_index, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(InitializedTypeInfo(method->klass)->rgctx_data, 4));
	const Il2CppFullySharedGenericAny L_4 = alloca(SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A);
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:120>
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = __this->___m_Data;
		int32_t L_1 = __this->___m_Start;
		int32_t L_2 = ___0_index;
		NullCheck(L_0);
		int32_t L_3 = ((int32_t)il2cpp_codegen_add(L_1, L_2));
		il2cpp_codegen_memcpy(L_4, (L_0)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_3)), SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A);
		il2cpp_codegen_memcpy(il2cppRetVal, L_4, SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A);
		return;
	}
}
IL2CPP_EXTERN_C  void WorkSlice_1_get_Item_mFDEC427E08156ECD6879AD45AEE3618B43E3F726_AdjustorThunk (RuntimeObject* __this, int32_t ___0_index, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method)
{
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*>(__this + _offset);
	WorkSlice_1_get_Item_mFDEC427E08156ECD6879AD45AEE3618B43E3F726(_thisAdjusted, ___0_index, il2cppRetVal, method);
	return;
}
// Method Definition Index: 56318
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1_set_Item_m757F8BE76FAE27C149DE7C474A2B1845E08A5A0F_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, int32_t ___0_index, Il2CppFullySharedGenericAny ___1_value, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(InitializedTypeInfo(method->klass)->rgctx_data, 4));
	const Il2CppFullySharedGenericAny L_3 = alloca(SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A);
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:121>
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = __this->___m_Data;
		int32_t L_1 = __this->___m_Start;
		int32_t L_2 = ___0_index;
		il2cpp_codegen_memcpy(L_3, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(InitializedTypeInfo(method->klass)->rgctx_data, 4)) ? ___1_value : &___1_value), SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A);
		NullCheck(L_0);
		il2cpp_codegen_memcpy((L_0)->GetAddressAt(static_cast<il2cpp_array_size_t>(((int32_t)il2cpp_codegen_add(L_1, L_2)))), L_3, SizeOf_T_tA71336896536EBCB168400E4D351FEE422324E7A);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(InitializedTypeInfo(method->klass)->rgctx_data, 4), (void**)(L_0)->GetAddressAt(static_cast<il2cpp_array_size_t>(((int32_t)il2cpp_codegen_add(L_1, L_2)))), (void*)L_3);
		return;
	}
}
IL2CPP_EXTERN_C  void WorkSlice_1_set_Item_m757F8BE76FAE27C149DE7C474A2B1845E08A5A0F_AdjustorThunk (RuntimeObject* __this, int32_t ___0_index, Il2CppFullySharedGenericAny ___1_value, const RuntimeMethod* method)
{
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*>(__this + _offset);
	WorkSlice_1_set_Item_m757F8BE76FAE27C149DE7C474A2B1845E08A5A0F(_thisAdjusted, ___0_index, ___1_value, method);
}
// Method Definition Index: 56319
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t WorkSlice_1_get_length_m7212817506EACBA1AB0D914DE401C6FA05F0DD9D_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:124>
		int32_t L_0 = __this->___m_Length;
		return L_0;
	}
}
IL2CPP_EXTERN_C  int32_t WorkSlice_1_get_length_m7212817506EACBA1AB0D914DE401C6FA05F0DD9D_AdjustorThunk (RuntimeObject* __this, const RuntimeMethod* method)
{
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*>(__this + _offset);
	int32_t _returnValue;
	_returnValue = WorkSlice_1_get_length_m7212817506EACBA1AB0D914DE401C6FA05F0DD9D_inline(_thisAdjusted, method);
	return _returnValue;
}
// Method Definition Index: 56320
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t WorkSlice_1_get_capacity_mCF0D603B7EC6E6037D0E1A14D8D0F49AD063E59E_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:125>
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_0 = __this->___m_Data;
		NullCheck(L_0);
		return ((int32_t)(((RuntimeArray*)L_0)->max_length));
	}
}
IL2CPP_EXTERN_C  int32_t WorkSlice_1_get_capacity_mCF0D603B7EC6E6037D0E1A14D8D0F49AD063E59E_AdjustorThunk (RuntimeObject* __this, const RuntimeMethod* method)
{
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*>(__this + _offset);
	int32_t _returnValue;
	_returnValue = WorkSlice_1_get_capacity_mCF0D603B7EC6E6037D0E1A14D8D0F49AD063E59E(_thisAdjusted, method);
	return _returnValue;
}
// Method Definition Index: 56321
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WorkSlice_1_Sort_mE2ED392BDF8F4F4141D7BF4C984EFE943F607A94_gshared (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9* ___0_compare, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Sorting_tBB4ACAADCAA21EA710DD3998A0614ABDEF8FD8A6_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:129>
		int32_t L_0 = __this->___m_Length;
		if ((((int32_t)L_0) <= ((int32_t)1)))
		{
			goto IL_002a;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:130>
		__Il2CppFullySharedGenericTypeU5BU5D_tCAB6D060972DD49223A834B7EEFEB9FE2D003BEC* L_1 = __this->___m_Data;
		int32_t L_2 = __this->___m_Start;
		int32_t L_3 = __this->___m_Start;
		int32_t L_4 = __this->___m_Length;
		Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9* L_5 = ___0_compare;
		il2cpp_codegen_runtime_class_init_inline(Sorting_tBB4ACAADCAA21EA710DD3998A0614ABDEF8FD8A6_il2cpp_TypeInfo_var);
		Sorting_QuickSort_TisIl2CppFullySharedGenericAny_mFECEFDEFE0154FD35AB3600D1EC1BCA3688FB81D(L_1, L_2, ((int32_t)il2cpp_codegen_subtract(((int32_t)il2cpp_codegen_add(L_3, L_4)), 1)), L_5, il2cpp_rgctx_method(InitializedTypeInfo(method->klass)->rgctx_data, 6));
	}

IL_002a:
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:131>
		return;
	}
}
IL2CPP_EXTERN_C  void WorkSlice_1_Sort_mE2ED392BDF8F4F4141D7BF4C984EFE943F607A94_AdjustorThunk (RuntimeObject* __this, Func_3_tECED1961B53AB164A131061296ABA1276B4FBBB9* ___0_compare, const RuntimeMethod* method)
{
	WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* _thisAdjusted;
	int32_t _offset = 1;
	_thisAdjusted = reinterpret_cast<WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809*>(__this + _offset);
	WorkSlice_1_Sort_mE2ED392BDF8F4F4141D7BF4C984EFE943F607A94(_thisAdjusted, ___0_compare, method);
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
void WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_Multicast(WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* __this, Il2CppFullySharedGenericAny* ___0_val, Il2CppFullySharedGenericAny ___1_fieldValue, const RuntimeMethod* method)
{
	il2cpp_array_size_t length = __this->___delegates->max_length;
	Delegate_t** delegatesToInvoke = reinterpret_cast<Delegate_t**>(__this->___delegates->GetAddressAtUnchecked(0));
	for (il2cpp_array_size_t i = 0; i < length; i++)
	{
		WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* currentDelegate = reinterpret_cast<WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7*>(delegatesToInvoke[i]);
		typedef void (*FunctionPointerType) (RuntimeObject*, Il2CppFullySharedGenericAny*, Il2CppFullySharedGenericAny, const RuntimeMethod*);
		((FunctionPointerType)currentDelegate->___invoke_impl)((Il2CppObject*)currentDelegate->___method_code, ___0_val, ___1_fieldValue, reinterpret_cast<RuntimeMethod*>(currentDelegate->___method));
	}
}
void WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_OpenStaticInvoker(WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* __this, Il2CppFullySharedGenericAny* ___0_val, Il2CppFullySharedGenericAny ___1_fieldValue, const RuntimeMethod* method)
{
	InvokerActionInvoker2< Il2CppFullySharedGenericAny*, Il2CppFullySharedGenericAny >::Invoke((Il2CppMethodPointer)__this->___method_ptr, method, NULL, ___0_val, ___1_fieldValue);
}
void WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_ClosedStaticInvoker(WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* __this, Il2CppFullySharedGenericAny* ___0_val, Il2CppFullySharedGenericAny ___1_fieldValue, const RuntimeMethod* method)
{
	InvokerActionInvoker3< RuntimeObject*, Il2CppFullySharedGenericAny*, Il2CppFullySharedGenericAny >::Invoke((Il2CppMethodPointer)__this->___method_ptr, method, NULL, __this->___m_target, ___0_val, ___1_fieldValue);
}
void WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_ClosedInstInvoker(WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* __this, Il2CppFullySharedGenericAny* ___0_val, Il2CppFullySharedGenericAny ___1_fieldValue, const RuntimeMethod* method)
{
	InvokerActionInvoker2< Il2CppFullySharedGenericAny*, Il2CppFullySharedGenericAny >::Invoke((Il2CppMethodPointer)__this->___method_ptr, method, __this->___m_target, ___0_val, ___1_fieldValue);
}
void WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_OpenInstInvoker(WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* __this, Il2CppFullySharedGenericAny* ___0_val, Il2CppFullySharedGenericAny ___1_fieldValue, const RuntimeMethod* method)
{
	NullCheck(___0_val);
	InvokerActionInvoker1< Il2CppFullySharedGenericAny >::Invoke((Il2CppMethodPointer)__this->___method_ptr, method, ___0_val, ___1_fieldValue);
}
// Method Definition Index: 13511
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WriteDelegate__ctor_mCE6F306923A685DD2E41E1BAABB666E0F7B4E137_gshared (WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* __this, RuntimeObject* ___0_object, intptr_t ___1_method, const RuntimeMethod* method) 
{
	__this->___method_ptr = (intptr_t)il2cpp_codegen_get_method_pointer((RuntimeMethod*)___1_method);
	__this->___method = ___1_method;
	__this->___m_target = ___0_object;
	Il2CppCodeGenWriteBarrier((void**)(&__this->___m_target), (void*)___0_object);
	int parameterCount = il2cpp_codegen_method_parameter_count((RuntimeMethod*)___1_method);
	__this->___method_code = (intptr_t)__this;
	if (MethodIsStatic((RuntimeMethod*)___1_method))
	{
		bool isOpen = parameterCount == 2;
		if (isOpen)
			__this->___invoke_impl = (intptr_t)&WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_OpenStaticInvoker;
		else
			__this->___invoke_impl = (intptr_t)&WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_ClosedStaticInvoker;
	}
	else
	{
		bool isOpen = parameterCount == 1;
		if (isOpen)
		{
			__this->___invoke_impl = (intptr_t)&WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_OpenInstInvoker;
		}
		else
		{
			if (___0_object == NULL)
				il2cpp_codegen_raise_exception(il2cpp_codegen_get_argument_exception(NULL, "Delegate to an instance method cannot have null 'this'."), NULL);
			__this->___invoke_impl = (intptr_t)&WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_ClosedInstInvoker;
		}
	}
	__this->___extra_arg = (intptr_t)&WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_Multicast;
}
// Method Definition Index: 13512
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void WriteDelegate_Invoke_m314AB1F8889F277917B21F5F09093D797490FE93_gshared (WriteDelegate_tCC7EDE8329D3D4B81ABF643CABCC600B2CC335D7* __this, Il2CppFullySharedGenericAny* ___0_val, Il2CppFullySharedGenericAny ___1_fieldValue, const RuntimeMethod* method) 
{
	typedef void (*FunctionPointerType) (RuntimeObject*, Il2CppFullySharedGenericAny*, Il2CppFullySharedGenericAny, const RuntimeMethod*);
	((FunctionPointerType)__this->___invoke_impl)((Il2CppObject*)__this->___method_code, ___0_val, ___1_fieldValue, reinterpret_cast<RuntimeMethod*>(__this->___method));
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 112908
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XHashtableState__ctor_mC2ED3CAB78829509332331B146E7165C58D3DD0F_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* ___0_extractKey, int32_t ___1_capacity, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C_il2cpp_TypeInfo_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2((RuntimeObject*)__this, NULL);
		int32_t L_0 = ___1_capacity;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_1 = (Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C*)(Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C*)SZArrayNew(Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C_il2cpp_TypeInfo_var, (uint32_t)L_0);
		__this->____buckets = L_1;
		Il2CppCodeGenWriteBarrier((void**)(&__this->____buckets), (void*)L_1);
		int32_t L_2 = ___1_capacity;
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_3 = (EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4*)(EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4*)SZArrayNew(il2cpp_rgctx_data(method->klass->rgctx_data, 1), (uint32_t)L_2);
		__this->____entries = L_3;
		Il2CppCodeGenWriteBarrier((void**)(&__this->____entries), (void*)L_3);
		ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* L_4 = ___0_extractKey;
		__this->____extractKey = L_4;
		Il2CppCodeGenWriteBarrier((void**)(&__this->____extractKey), (void*)L_4);
		return;
	}
}
// Method Definition Index: 112909
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* XHashtableState_Resize_m3CD152F50AD9E53B808C9B1CEC069D894A621202_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5));
	const Il2CppFullySharedGenericAny L_13 = alloca(SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
	const Il2CppFullySharedGenericAny L_45 = L_13;
	int32_t V_0 = 0;
	XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* V_1 = NULL;
	int32_t V_2 = 0;
	int32_t V_3 = 0;
	int32_t V_4 = 0;
	int32_t V_5 = 0;
	Il2CppFullySharedGenericAny V_6 = alloca(SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
	memset(V_6, 0, SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
	{
		int32_t L_0 = __this->____numEntries;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_1 = __this->____buckets;
		NullCheck(L_1);
		if ((((int32_t)L_0) >= ((int32_t)((int32_t)(((RuntimeArray*)L_1)->max_length)))))
		{
			goto IL_0012;
		}
	}
	{
		return __this;
	}

IL_0012:
	{
		V_0 = 0;
		V_2 = 0;
		goto IL_00a7;
	}

IL_001b:
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_2 = __this->____buckets;
		int32_t L_3 = V_2;
		NullCheck(L_2);
		int32_t L_4 = L_3;
		int32_t L_5 = (L_2)->GetAt(static_cast<il2cpp_array_size_t>(L_4));
		V_3 = L_5;
		int32_t L_6 = V_3;
		if (L_6)
		{
			goto IL_009f;
		}
	}
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_7 = __this->____buckets;
		int32_t L_8 = V_2;
		NullCheck(L_7);
		int32_t L_9;
		L_9 = Interlocked_CompareExchange_mB06E8737D3DA41F9FFBC38A6D0583D515EFB5717(((L_7)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_8))), (-1), 0, NULL);
		V_3 = L_9;
		goto IL_009f;
	}

IL_003d:
	{
		ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* L_10 = __this->____extractKey;
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_11 = __this->____entries;
		int32_t L_12 = V_3;
		NullCheck(L_11);
		il2cpp_codegen_memcpy(L_13, il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_11)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_12))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),0)), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		NullCheck(L_10);
		String_t* L_14;
		L_14 = ExtractKeyDelegate_Invoke_m299616CF7575CD317723CE89D3BA8B8F04A9B722_inline(L_10, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5)) ? L_13: *(void**)L_13), il2cpp_rgctx_method(method->klass->rgctx_data, 6));
		if (!L_14)
		{
			goto IL_005f;
		}
	}
	{
		int32_t L_15 = V_0;
		V_0 = ((int32_t)il2cpp_codegen_add(L_15, 1));
	}

IL_005f:
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_16 = __this->____entries;
		int32_t L_17 = V_3;
		NullCheck(L_16);
		int32_t L_18 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_16)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_17))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2));
		if (L_18)
		{
			goto IL_008d;
		}
	}
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_19 = __this->____entries;
		int32_t L_20 = V_3;
		NullCheck(L_19);
		int32_t L_21;
		L_21 = Interlocked_CompareExchange_mB06E8737D3DA41F9FFBC38A6D0583D515EFB5717((((int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_19)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_20))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2)))), (-1), 0, NULL);
		V_3 = L_21;
		goto IL_009f;
	}

IL_008d:
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_22 = __this->____entries;
		int32_t L_23 = V_3;
		NullCheck(L_22);
		int32_t L_24 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_22)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_23))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2));
		V_3 = L_24;
	}

IL_009f:
	{
		int32_t L_25 = V_3;
		if ((((int32_t)L_25) > ((int32_t)0)))
		{
			goto IL_003d;
		}
	}
	{
		int32_t L_26 = V_2;
		V_2 = ((int32_t)il2cpp_codegen_add(L_26, 1));
	}

IL_00a7:
	{
		int32_t L_27 = V_2;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_28 = __this->____buckets;
		NullCheck(L_28);
		if ((((int32_t)L_27) < ((int32_t)((int32_t)(((RuntimeArray*)L_28)->max_length)))))
		{
			goto IL_001b;
		}
	}
	{
		int32_t L_29 = V_0;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_30 = __this->____buckets;
		NullCheck(L_30);
		if ((((int32_t)L_29) >= ((int32_t)((int32_t)(((int32_t)(((RuntimeArray*)L_30)->max_length))/2)))))
		{
			goto IL_00cd;
		}
	}
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_31 = __this->____buckets;
		NullCheck(L_31);
		V_0 = ((int32_t)(((RuntimeArray*)L_31)->max_length));
		goto IL_00e2;
	}

IL_00cd:
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_32 = __this->____buckets;
		NullCheck(L_32);
		V_0 = ((int32_t)il2cpp_codegen_multiply(((int32_t)(((RuntimeArray*)L_32)->max_length)), 2));
		int32_t L_33 = V_0;
		if ((((int32_t)L_33) >= ((int32_t)0)))
		{
			goto IL_00e2;
		}
	}
	{
		OverflowException_t6F6AD8CACE20C37F701C05B373A215C4802FAB0C* L_34 = (OverflowException_t6F6AD8CACE20C37F701C05B373A215C4802FAB0C*)il2cpp_codegen_object_new(((RuntimeClass*)il2cpp_codegen_initialize_runtime_metadata_inline((uintptr_t*)&OverflowException_t6F6AD8CACE20C37F701C05B373A215C4802FAB0C_il2cpp_TypeInfo_var)));
		OverflowException__ctor_m7F6A928C9BE47384586BDDE8B4B87666421E0F1A(L_34, NULL);
		IL2CPP_RAISE_MANAGED_EXCEPTION(L_34, method);
	}

IL_00e2:
	{
		ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* L_35 = __this->____extractKey;
		int32_t L_36 = V_0;
		XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_37 = (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 0));
		XHashtableState__ctor_mC2ED3CAB78829509332331B146E7165C58D3DD0F(L_37, L_35, L_36, il2cpp_rgctx_method(method->klass->rgctx_data, 7));
		V_1 = L_37;
		V_4 = 0;
		goto IL_013b;
	}

IL_00f4:
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_38 = __this->____buckets;
		int32_t L_39 = V_4;
		NullCheck(L_38);
		int32_t L_40 = L_39;
		int32_t L_41 = (L_38)->GetAt(static_cast<il2cpp_array_size_t>(L_40));
		V_5 = L_41;
		goto IL_0130;
	}

IL_0101:
	{
		XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_42 = V_1;
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_43 = __this->____entries;
		int32_t L_44 = V_5;
		NullCheck(L_43);
		il2cpp_codegen_memcpy(L_45, il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_43)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_44))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),0)), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		NullCheck(L_42);
		bool L_46;
		L_46 = XHashtableState_TryAdd_m25BEF4B433B3B23CE79C25AA27DA2FFB624CCAE2(L_42, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5)) ? L_45: *(void**)L_45), (Il2CppFullySharedGenericAny*)V_6, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_47 = __this->____entries;
		int32_t L_48 = V_5;
		NullCheck(L_47);
		int32_t L_49 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_47)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_48))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2));
		V_5 = L_49;
	}

IL_0130:
	{
		int32_t L_50 = V_5;
		if ((((int32_t)L_50) > ((int32_t)0)))
		{
			goto IL_0101;
		}
	}
	{
		int32_t L_51 = V_4;
		V_4 = ((int32_t)il2cpp_codegen_add(L_51, 1));
	}

IL_013b:
	{
		int32_t L_52 = V_4;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_53 = __this->____buckets;
		NullCheck(L_53);
		if ((((int32_t)L_52) < ((int32_t)((int32_t)(((RuntimeArray*)L_53)->max_length)))))
		{
			goto IL_00f4;
		}
	}
	{
		XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_54 = V_1;
		return L_54;
	}
}
// Method Definition Index: 112910
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XHashtableState_TryGetValue_m94EE8AEAE527C34D9D2B86D03E1D04FF867266F3_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, String_t* ___0_key, int32_t ___1_index, int32_t ___2_count, Il2CppFullySharedGenericAny* ___3_value, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5));
	const Il2CppFullySharedGenericAny L_12 = alloca(SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
	int32_t V_0 = 0;
	int32_t V_1 = 0;
	{
		String_t* L_0 = ___0_key;
		int32_t L_1 = ___1_index;
		int32_t L_2 = ___2_count;
		int32_t L_3;
		L_3 = XHashtableState_ComputeHashCode_m52BA0BD18441AD2A49C4E822AB76A7A5B7DC4B6D(L_0, L_1, L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		V_0 = L_3;
		V_1 = 0;
		int32_t L_4 = V_0;
		String_t* L_5 = ___0_key;
		int32_t L_6 = ___1_index;
		int32_t L_7 = ___2_count;
		bool L_8;
		L_8 = XHashtableState_FindEntry_m480C6B27D99709A7E6CB50C907ACDEA057992BCD(__this, L_4, L_5, L_6, L_7, (&V_1), il2cpp_rgctx_method(method->klass->rgctx_data, 12));
		if (!L_8)
		{
			goto IL_0033;
		}
	}
	{
		Il2CppFullySharedGenericAny* L_9 = ___3_value;
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_10 = __this->____entries;
		int32_t L_11 = V_1;
		NullCheck(L_10);
		il2cpp_codegen_memcpy(L_12, il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_10)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_11))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),0)), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_9, L_12, SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->klass->rgctx_data, 5), (void**)(Il2CppFullySharedGenericAny*)L_9, (void*)L_12);
		return (bool)1;
	}

IL_0033:
	{
		Il2CppFullySharedGenericAny* L_13 = ___3_value;
		il2cpp_codegen_initobj(L_13, SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		return (bool)0;
	}
}
// Method Definition Index: 112911
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XHashtableState_TryAdd_m25BEF4B433B3B23CE79C25AA27DA2FFB624CCAE2_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, Il2CppFullySharedGenericAny ___0_value, Il2CppFullySharedGenericAny* ___1_newValue, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5));
	const Il2CppFullySharedGenericAny L_1 = alloca(SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
	const Il2CppFullySharedGenericAny L_17 = L_1;
	const Il2CppFullySharedGenericAny L_41 = L_1;
	const Il2CppFullySharedGenericAny L_3 = alloca(SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
	int32_t V_0 = 0;
	int32_t V_1 = 0;
	String_t* V_2 = NULL;
	int32_t V_3 = 0;
	{
		Il2CppFullySharedGenericAny* L_0 = ___1_newValue;
		il2cpp_codegen_memcpy(L_1, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5)) ? ___0_value : &___0_value), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_0, L_1, SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->klass->rgctx_data, 5), (void**)(Il2CppFullySharedGenericAny*)L_0, (void*)L_1);
		ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* L_2 = __this->____extractKey;
		il2cpp_codegen_memcpy(L_3, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5)) ? ___0_value : &___0_value), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		NullCheck(L_2);
		String_t* L_4;
		L_4 = ExtractKeyDelegate_Invoke_m299616CF7575CD317723CE89D3BA8B8F04A9B722_inline(L_2, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5)) ? L_3: *(void**)L_3), il2cpp_rgctx_method(method->klass->rgctx_data, 6));
		V_2 = L_4;
		String_t* L_5 = V_2;
		if (L_5)
		{
			goto IL_0019;
		}
	}
	{
		return (bool)1;
	}

IL_0019:
	{
		String_t* L_6 = V_2;
		String_t* L_7 = V_2;
		NullCheck(L_7);
		int32_t L_8;
		L_8 = String_get_Length_m42625D67623FA5CC7A44D47425CE86FB946542D2_inline(L_7, NULL);
		int32_t L_9;
		L_9 = XHashtableState_ComputeHashCode_m52BA0BD18441AD2A49C4E822AB76A7A5B7DC4B6D(L_6, 0, L_8, il2cpp_rgctx_method(method->klass->rgctx_data, 10));
		V_3 = L_9;
		int32_t* L_10 = (int32_t*)(&__this->____numEntries);
		int32_t L_11;
		L_11 = Interlocked_Increment_m3C240C32E8D9544EC050B74D4F28EEB58F1F9309(L_10, NULL);
		V_0 = L_11;
		int32_t L_12 = V_0;
		if ((((int32_t)L_12) < ((int32_t)0)))
		{
			goto IL_0042;
		}
	}
	{
		int32_t L_13 = V_0;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_14 = __this->____buckets;
		NullCheck(L_14);
		if ((((int32_t)L_13) < ((int32_t)((int32_t)(((RuntimeArray*)L_14)->max_length)))))
		{
			goto IL_0044;
		}
	}

IL_0042:
	{
		return (bool)0;
	}

IL_0044:
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_15 = __this->____entries;
		int32_t L_16 = V_0;
		NullCheck(L_15);
		il2cpp_codegen_memcpy(L_17, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5)) ? ___0_value : &___0_value), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		il2cpp_codegen_write_instance_field_data(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_15)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_16))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),0), L_17, SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_18 = __this->____entries;
		int32_t L_19 = V_0;
		NullCheck(L_18);
		int32_t L_20 = V_3;
		il2cpp_codegen_write_instance_field_data<int32_t>(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_18)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_19))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),1), L_20);
		Thread_MemoryBarrier_m83873F1E6CEB16C0781941141382DA874A36097D(NULL);
		V_1 = 0;
		goto IL_00b7;
	}

IL_0071:
	{
		int32_t L_21 = V_1;
		if (L_21)
		{
			goto IL_0095;
		}
	}
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_22 = __this->____buckets;
		int32_t L_23 = V_3;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_24 = __this->____buckets;
		NullCheck(L_24);
		NullCheck(L_22);
		int32_t L_25 = V_0;
		int32_t L_26;
		L_26 = Interlocked_CompareExchange_mB06E8737D3DA41F9FFBC38A6D0583D515EFB5717(((L_22)->GetAddressAt(static_cast<il2cpp_array_size_t>(((int32_t)(L_23&((int32_t)il2cpp_codegen_subtract(((int32_t)(((RuntimeArray*)L_24)->max_length)), 1))))))), L_25, 0, NULL);
		V_1 = L_26;
		goto IL_00ae;
	}

IL_0095:
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_27 = __this->____entries;
		int32_t L_28 = V_1;
		NullCheck(L_27);
		int32_t L_29 = V_0;
		int32_t L_30;
		L_30 = Interlocked_CompareExchange_mB06E8737D3DA41F9FFBC38A6D0583D515EFB5717((((int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_27)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_28))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2)))), L_29, 0, NULL);
		V_1 = L_30;
	}

IL_00ae:
	{
		int32_t L_31 = V_1;
		if ((((int32_t)L_31) > ((int32_t)0)))
		{
			goto IL_00b7;
		}
	}
	{
		int32_t L_32 = V_1;
		return (bool)((((int32_t)L_32) == ((int32_t)0))? 1 : 0);
	}

IL_00b7:
	{
		int32_t L_33 = V_3;
		String_t* L_34 = V_2;
		String_t* L_35 = V_2;
		NullCheck(L_35);
		int32_t L_36;
		L_36 = String_get_Length_m42625D67623FA5CC7A44D47425CE86FB946542D2_inline(L_35, NULL);
		bool L_37;
		L_37 = XHashtableState_FindEntry_m480C6B27D99709A7E6CB50C907ACDEA057992BCD(__this, L_33, L_34, 0, L_36, (&V_1), il2cpp_rgctx_method(method->klass->rgctx_data, 12));
		if (!L_37)
		{
			goto IL_0071;
		}
	}
	{
		Il2CppFullySharedGenericAny* L_38 = ___1_newValue;
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_39 = __this->____entries;
		int32_t L_40 = V_1;
		NullCheck(L_39);
		il2cpp_codegen_memcpy(L_41, il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_39)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_40))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),0)), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericAny*)L_38, L_41, SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->klass->rgctx_data, 5), (void**)(Il2CppFullySharedGenericAny*)L_38, (void*)L_41);
		return (bool)1;
	}
}
// Method Definition Index: 112912
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XHashtableState_FindEntry_m480C6B27D99709A7E6CB50C907ACDEA057992BCD_gshared (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* __this, int32_t ___0_hashCode, String_t* ___1_key, int32_t ___2_index, int32_t ___3_count, int32_t* ___4_entryIndex, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5));
	const Il2CppFullySharedGenericAny L_16 = alloca(SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
	int32_t V_0 = 0;
	int32_t V_1 = 0;
	String_t* V_2 = NULL;
	{
		int32_t* L_0 = ___4_entryIndex;
		int32_t L_1 = *((int32_t*)L_0);
		V_0 = L_1;
		int32_t L_2 = V_0;
		if (L_2)
		{
			goto IL_0020;
		}
	}
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_3 = __this->____buckets;
		int32_t L_4 = ___0_hashCode;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_5 = __this->____buckets;
		NullCheck(L_5);
		NullCheck(L_3);
		int32_t L_6 = ((int32_t)(L_4&((int32_t)il2cpp_codegen_subtract(((int32_t)(((RuntimeArray*)L_5)->max_length)), 1))));
		int32_t L_7 = (L_3)->GetAt(static_cast<il2cpp_array_size_t>(L_6));
		V_1 = L_7;
		goto IL_00f9;
	}

IL_0020:
	{
		int32_t L_8 = V_0;
		V_1 = L_8;
		goto IL_00f9;
	}

IL_0027:
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_9 = __this->____entries;
		int32_t L_10 = V_1;
		NullCheck(L_9);
		int32_t L_11 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_9)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_10))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),1));
		int32_t L_12 = ___0_hashCode;
		if ((!(((uint32_t)L_11) == ((uint32_t)L_12))))
		{
			goto IL_00e5;
		}
	}
	{
		ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* L_13 = __this->____extractKey;
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_14 = __this->____entries;
		int32_t L_15 = V_1;
		NullCheck(L_14);
		il2cpp_codegen_memcpy(L_16, il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_14)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_15))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),0)), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		NullCheck(L_13);
		String_t* L_17;
		L_17 = ExtractKeyDelegate_Invoke_m299616CF7575CD317723CE89D3BA8B8F04A9B722_inline(L_13, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 5)) ? L_16: *(void**)L_16), il2cpp_rgctx_method(method->klass->rgctx_data, 6));
		V_2 = L_17;
		String_t* L_18 = V_2;
		if (L_18)
		{
			goto IL_00c8;
		}
	}
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_19 = __this->____entries;
		int32_t L_20 = V_1;
		NullCheck(L_19);
		int32_t L_21 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_19)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_20))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2));
		if ((((int32_t)L_21) <= ((int32_t)0)))
		{
			goto IL_00e5;
		}
	}
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_22 = __this->____entries;
		int32_t L_23 = V_1;
		NullCheck(L_22);
		il2cpp_codegen_initobj((((Il2CppFullySharedGenericAny*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_22)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_23))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),0)))), SizeOf_TValue_tE0E843520D1B6FE8622D14458F0B584A2B7BCD70);
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_24 = __this->____entries;
		int32_t L_25 = V_1;
		NullCheck(L_24);
		int32_t L_26 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_24)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_25))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2));
		V_1 = L_26;
		int32_t L_27 = V_0;
		if (L_27)
		{
			goto IL_00b4;
		}
	}
	{
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_28 = __this->____buckets;
		int32_t L_29 = ___0_hashCode;
		Int32U5BU5D_t19C97395396A72ECAF310612F0760F165060314C* L_30 = __this->____buckets;
		NullCheck(L_30);
		int32_t L_31 = V_1;
		NullCheck(L_28);
		(L_28)->SetAt(static_cast<il2cpp_array_size_t>(((int32_t)(L_29&((int32_t)il2cpp_codegen_subtract(((int32_t)(((RuntimeArray*)L_30)->max_length)), 1))))), (int32_t)L_31);
		goto IL_00f9;
	}

IL_00b4:
	{
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_32 = __this->____entries;
		int32_t L_33 = V_0;
		NullCheck(L_32);
		int32_t L_34 = V_1;
		il2cpp_codegen_write_instance_field_data<int32_t>(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_32)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_33))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2), L_34);
		goto IL_00f9;
	}

IL_00c8:
	{
		int32_t L_35 = ___3_count;
		String_t* L_36 = V_2;
		NullCheck(L_36);
		int32_t L_37;
		L_37 = String_get_Length_m42625D67623FA5CC7A44D47425CE86FB946542D2_inline(L_36, NULL);
		if ((!(((uint32_t)L_35) == ((uint32_t)L_37))))
		{
			goto IL_00e5;
		}
	}
	{
		String_t* L_38 = ___1_key;
		int32_t L_39 = ___2_index;
		String_t* L_40 = V_2;
		int32_t L_41 = ___3_count;
		int32_t L_42;
		L_42 = String_CompareOrdinal_m8940CFAE90021ED8DA3F2DF8226941C9EEB2E32D(L_38, L_39, L_40, 0, L_41, NULL);
		if (L_42)
		{
			goto IL_00e5;
		}
	}
	{
		int32_t* L_43 = ___4_entryIndex;
		int32_t L_44 = V_1;
		*((int32_t*)L_43) = (int32_t)L_44;
		return (bool)1;
	}

IL_00e5:
	{
		int32_t L_45 = V_1;
		V_0 = L_45;
		EntryU5BU5D_tD3CC9C2488DC949FC30141F89404B8BDA9DB6CE4* L_46 = __this->____entries;
		int32_t L_47 = V_1;
		NullCheck(L_46);
		int32_t L_48 = *(int32_t*)il2cpp_codegen_get_instance_field_data_pointer(((Entry_t7F8922DC9D131FDA94BF956DD509FC395285A91E*)(L_46)->GetAddressAt(static_cast<il2cpp_array_size_t>(L_47))), il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 4),2));
		V_1 = L_48;
	}

IL_00f9:
	{
		int32_t L_49 = V_1;
		if ((((int32_t)L_49) > ((int32_t)0)))
		{
			goto IL_0027;
		}
	}
	{
		int32_t* L_50 = ___4_entryIndex;
		int32_t L_51 = V_0;
		*((int32_t*)L_50) = (int32_t)L_51;
		return (bool)0;
	}
}
// Method Definition Index: 112913
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR int32_t XHashtableState_ComputeHashCode_m52BA0BD18441AD2A49C4E822AB76A7A5B7DC4B6D_gshared (String_t* ___0_key, int32_t ___1_index, int32_t ___2_count, const RuntimeMethod* method) 
{
	int32_t V_0 = 0;
	int32_t V_1 = 0;
	int32_t V_2 = 0;
	{
		V_0 = ((int32_t)352654597);
		int32_t L_0 = ___1_index;
		int32_t L_1 = ___2_count;
		V_1 = ((int32_t)il2cpp_codegen_add(L_0, L_1));
		int32_t L_2 = ___1_index;
		V_2 = L_2;
		goto IL_0020;
	}

IL_000e:
	{
		int32_t L_3 = V_0;
		int32_t L_4 = V_0;
		String_t* L_5 = ___0_key;
		int32_t L_6 = V_2;
		NullCheck(L_5);
		Il2CppChar L_7;
		L_7 = String_get_Chars_mC49DF0CD2D3BE7BE97B3AD9C995BE3094F8E36D3(L_5, L_6, NULL);
		V_0 = ((int32_t)il2cpp_codegen_add(L_3, ((int32_t)(((int32_t)(L_4<<7))^(int32_t)L_7))));
		int32_t L_8 = V_2;
		V_2 = ((int32_t)il2cpp_codegen_add(L_8, 1));
	}

IL_0020:
	{
		int32_t L_9 = V_2;
		int32_t L_10 = V_1;
		if ((((int32_t)L_9) < ((int32_t)L_10)))
		{
			goto IL_000e;
		}
	}
	{
		int32_t L_11 = V_0;
		int32_t L_12 = V_0;
		V_0 = ((int32_t)il2cpp_codegen_subtract(L_11, ((int32_t)(L_12>>((int32_t)17)))));
		int32_t L_13 = V_0;
		int32_t L_14 = V_0;
		V_0 = ((int32_t)il2cpp_codegen_subtract(L_13, ((int32_t)(L_14>>((int32_t)11)))));
		int32_t L_15 = V_0;
		int32_t L_16 = V_0;
		V_0 = ((int32_t)il2cpp_codegen_subtract(L_15, ((int32_t)(L_16>>5))));
		int32_t L_17 = V_0;
		return ((int32_t)(L_17&((int32_t)2147483647LL)));
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 112903
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XHashtable_1__ctor_m76AD29BB3D4A65A3071FDFCC0AD7F927FC6051B7_gshared (XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0* __this, ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* ___0_extractKey, int32_t ___1_capacity, const RuntimeMethod* method) 
{
	{
		Object__ctor_mE837C6B9FA8C6D5D109F4B2EC885D79919AC0EA2((RuntimeObject*)__this, NULL);
		ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* L_0 = ___0_extractKey;
		int32_t L_1 = ___1_capacity;
		XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_2 = (XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 1));
		XHashtableState__ctor_mC2ED3CAB78829509332331B146E7165C58D3DD0F(L_2, L_0, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		__this->____state = L_2;
		Il2CppCodeGenWriteBarrier((void**)(&__this->____state), (void*)L_2);
		return;
	}
}
// Method Definition Index: 112904
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XHashtable_1_TryGetValue_m2AE37A0F57ADCA202E17A64CCAF4D0F37A070A24_gshared (XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0* __this, String_t* ___0_key, int32_t ___1_index, int32_t ___2_count, Il2CppFullySharedGenericAny* ___3_value, const RuntimeMethod* method) 
{
	{
		XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_0 = __this->____state;
		String_t* L_1 = ___0_key;
		int32_t L_2 = ___1_index;
		int32_t L_3 = ___2_count;
		Il2CppFullySharedGenericAny* L_4 = ___3_value;
		NullCheck(L_0);
		bool L_5;
		L_5 = XHashtableState_TryGetValue_m94EE8AEAE527C34D9D2B86D03E1D04FF867266F3(L_0, L_1, L_2, L_3, L_4, il2cpp_rgctx_method(method->klass->rgctx_data, 5));
		return L_5;
	}
}
// Method Definition Index: 112905
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XHashtable_1_Add_mB4B8BF6CA81EE97D92FEE9D365A8FFB15168AE00_gshared (XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0* __this, Il2CppFullySharedGenericAny ___0_value, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t3953344BBD5AABD452C9834A9E3F75B5A767B1A7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6));
	const Il2CppFullySharedGenericAny L_1 = alloca(SizeOf_TValue_t3953344BBD5AABD452C9834A9E3F75B5A767B1A7);
	const Il2CppFullySharedGenericAny L_3 = L_1;
	Il2CppFullySharedGenericAny V_0 = alloca(SizeOf_TValue_t3953344BBD5AABD452C9834A9E3F75B5A767B1A7);
	memset(V_0, 0, SizeOf_TValue_t3953344BBD5AABD452C9834A9E3F75B5A767B1A7);
	XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0* V_1 = NULL;
	bool V_2 = false;
	XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* V_3 = NULL;

IL_0000:
	{
		XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_0 = __this->____state;
		il2cpp_codegen_memcpy(L_1, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6)) ? ___0_value : &___0_value), SizeOf_TValue_t3953344BBD5AABD452C9834A9E3F75B5A767B1A7);
		NullCheck(L_0);
		bool L_2;
		L_2 = XHashtableState_TryAdd_m25BEF4B433B3B23CE79C25AA27DA2FFB624CCAE2(L_0, (il2cpp_codegen_class_is_value_type(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 6)) ? L_1: *(void**)L_1), (Il2CppFullySharedGenericAny*)V_0, il2cpp_rgctx_method(method->klass->rgctx_data, 7));
		if (!L_2)
		{
			goto IL_0012;
		}
	}
	{
		il2cpp_codegen_memcpy(L_3, V_0, SizeOf_TValue_t3953344BBD5AABD452C9834A9E3F75B5A767B1A7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_3, SizeOf_TValue_t3953344BBD5AABD452C9834A9E3F75B5A767B1A7);
		return;
	}

IL_0012:
	{
		V_1 = __this;
		V_2 = (bool)0;
	}
	{
		auto __finallyBlock = il2cpp::utils::Finally([&]
		{

FINALLY_0038:
			{
				{
					bool L_4 = V_2;
					if (!L_4)
					{
						goto IL_0041;
					}
				}
				{
					XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0* L_5 = V_1;
					Monitor_Exit_m05B2CF037E2214B3208198C282490A2A475653FA((RuntimeObject*)L_5, NULL);
				}

IL_0041:
				{
					return;
				}
			}
		});
		try
		{
			XHashtable_1_t781B821CC6AC13BED190536310819EB7FD1463D0* L_6 = V_1;
			Monitor_Enter_m3CDB589DA1300B513D55FDCFB52B63E879794149((RuntimeObject*)L_6, (&V_2), NULL);
			XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_7 = __this->____state;
			NullCheck(L_7);
			XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_8;
			L_8 = XHashtableState_Resize_m3CD152F50AD9E53B808C9B1CEC069D894A621202(L_7, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
			V_3 = L_8;
			Thread_MemoryBarrier_m83873F1E6CEB16C0781941141382DA874A36097D(NULL);
			XHashtableState_t34177FC58180B0A7A606129FC1FA6AF4C373043D* L_9 = V_3;
			__this->____state = L_9;
			Il2CppCodeGenWriteBarrier((void**)(&__this->____state), (void*)L_9);
			goto IL_0000;
		}
		catch(Il2CppExceptionWrapper& e)
		{
			__finallyBlock.StoreException(e.ex);
		}
	}
	il2cpp_codegen_no_return();
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 30034
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* XRInputDeviceValueReader_1_get_usage_m51F48ED988A97FC802827ABC0BB2FB75F971ABC5_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:49>
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_0 = __this->___m_Usage;
		return L_0;
	}
}
// Method Definition Index: 30035
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputDeviceValueReader_1_set_usage_mAD9D1335AC070AB967F71AFAB1DEAC7DE7B78E6C_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* ___0_value, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:50>
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_0 = ___0_value;
		__this->___m_Usage = L_0;
		Il2CppCodeGenWriteBarrier((void**)(&__this->___m_Usage), (void*)L_0);
		return;
	}
}
// Method Definition Index: 30038
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_ReadBoolValue_m2001C8BA8B0638BEDFB2582345CE2D5E2D767835_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	bool V_0 = false;
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:67>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0029;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_tE336B2F0B9AC721519BFA17A08D6353FD5221637 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7((&L_4), L_3, InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7_RuntimeMethod_var);
		bool L_5;
		L_5 = InputDevice_TryGetFeatureValue_m24EC3B6C41AE4098269427232AD5F52E786BF884(L_1, L_4, (&V_0), NULL);
		if (!L_5)
		{
			goto IL_0029;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:68>
		bool L_6 = V_0;
		return L_6;
	}

IL_0029:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:70>
		return (bool)0;
	}
}
// Method Definition Index: 30039
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR uint32_t XRInputDeviceValueReader_1_ReadUIntValue_mFDFD16DB71C231A037A1A57388051BA55AE48217_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	uint32_t V_0 = 0;
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:79>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0029;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_tD73AC74B29139087A83959CB3395A0580A2128AE L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0((&L_4), L_3, InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0_RuntimeMethod_var);
		bool L_5;
		L_5 = InputDevice_TryGetFeatureValue_m9FC969BEFF0E5BAB78DD9F2130F437788D20068C(L_1, L_4, (&V_0), NULL);
		if (!L_5)
		{
			goto IL_0029;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:80>
		uint32_t L_6 = V_0;
		return L_6;
	}

IL_0029:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:82>
		return (uint32_t)0;
	}
}
// Method Definition Index: 30040
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR float XRInputDeviceValueReader_1_ReadFloatValue_mBCC31B41C0D092595219A441E8E3433703534D09_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	float V_0 = 0.0f;
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:91>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0029;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t311D0F42F1A7BF37D3CEAC15A53A1F24165F1848 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989((&L_4), L_3, InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989_RuntimeMethod_var);
		bool L_5;
		L_5 = InputDevice_TryGetFeatureValue_m675D52240379FEF80D6499B5031941812FDFD081(L_1, L_4, (&V_0), NULL);
		if (!L_5)
		{
			goto IL_0029;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:92>
		float L_6 = V_0;
		return L_6;
	}

IL_0029:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:94>
		return (0.0f);
	}
}
// Method Definition Index: 30041
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 XRInputDeviceValueReader_1_ReadVector2Value_m42A9609BFF742DC74C96E9204D5AA9DF3F1455F3_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 V_0;
	memset((&V_0), 0, sizeof(V_0));
	Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 V_1;
	memset((&V_1), 0, sizeof(V_1));
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:103>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0029;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_tEB160A05BCDCCA4F96072CBA0866498D06B9A27C L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A((&L_4), L_3, InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A_RuntimeMethod_var);
		bool L_5;
		L_5 = InputDevice_TryGetFeatureValue_mB2C15D1FC747DA9FB5958FA17E77049886FB3BBA(L_1, L_4, (&V_0), NULL);
		if (!L_5)
		{
			goto IL_0029;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:104>
		Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 L_6 = V_0;
		return L_6;
	}

IL_0029:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:106>
		il2cpp_codegen_initobj((&V_1), sizeof(Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7));
		Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7 L_7 = V_1;
		return L_7;
	}
}
// Method Definition Index: 30042
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 XRInputDeviceValueReader_1_ReadVector3Value_m96F9F4A33D5CA9A3D6E7327B9B7FE5FB03FF3C45_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 V_0;
	memset((&V_0), 0, sizeof(V_0));
	Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 V_1;
	memset((&V_1), 0, sizeof(V_1));
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:115>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0029;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t2E901FA41650EB29399194768CAA93D477CEBC58 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA((&L_4), L_3, InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA_RuntimeMethod_var);
		bool L_5;
		L_5 = InputDevice_TryGetFeatureValue_m472B5ECE996FB7440CACCF1E85722DA4963E3167(L_1, L_4, (&V_0), NULL);
		if (!L_5)
		{
			goto IL_0029;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:116>
		Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 L_6 = V_0;
		return L_6;
	}

IL_0029:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:118>
		il2cpp_codegen_initobj((&V_1), sizeof(Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2));
		Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2 L_7 = V_1;
		return L_7;
	}
}
// Method Definition Index: 30043
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974 XRInputDeviceValueReader_1_ReadQuaternionValue_mF72D05FB881D857AAE9656B9BE5FB229A6145B5C_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974 V_0;
	memset((&V_0), 0, sizeof(V_0));
	Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974 V_1;
	memset((&V_1), 0, sizeof(V_1));
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:127>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0029;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t8489CEC68B1EC178F2634079A9D7CD9E90D3CF5D L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08((&L_4), L_3, InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08_RuntimeMethod_var);
		bool L_5;
		L_5 = InputDevice_TryGetFeatureValue_m0C1A9761DD0D1C6D1EF4BAB2FAF1BC1A9541BB9F(L_1, L_4, (&V_0), NULL);
		if (!L_5)
		{
			goto IL_0029;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:128>
		Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974 L_6 = V_0;
		return L_6;
	}

IL_0029:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:130>
		il2cpp_codegen_initobj((&V_1), sizeof(Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974));
		Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974 L_7 = V_1;
		return L_7;
	}
}
// Method Definition Index: 30044
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR uint32_t XRInputDeviceValueReader_1_ReadInputTrackingStateValue_mDC1787334BA972E01FEF4D773F170640048830C1_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	uint32_t V_0 = 0;
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:139>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0029;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t4EF7DDCAC35EE23BA72694AC2AB76CF4A879FFD9 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55((&L_4), L_3, InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55_RuntimeMethod_var);
		bool L_5;
		L_5 = InputDevice_TryGetFeatureValue_m8A01F07356DC85042F6BB7C6258A75C3EC3C4E11(L_1, L_4, (&V_0), NULL);
		if (!L_5)
		{
			goto IL_0029;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:140>
		uint32_t L_6 = V_0;
		return L_6;
	}

IL_0029:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:142>
		return (uint32_t)(0);
	}
}
// Method Definition Index: 30045
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_TryReadBoolValue_mEA97CE264949878E5E914906CEF1DACF289C129A_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, bool* ___0_value, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:152>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0028;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_tE336B2F0B9AC721519BFA17A08D6353FD5221637 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7((&L_4), L_3, InputFeatureUsage_1__ctor_mEB36F8937385A1065CD9F48AE2DAD9EAE49EFCE7_RuntimeMethod_var);
		bool* L_5 = ___0_value;
		bool L_6;
		L_6 = InputDevice_TryGetFeatureValue_m24EC3B6C41AE4098269427232AD5F52E786BF884(L_1, L_4, L_5, NULL);
		if (!L_6)
		{
			goto IL_0028;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:153>
		return (bool)1;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:155>
		bool* L_7 = ___0_value;
		*((int8_t*)L_7) = (int8_t)0;
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:156>
		return (bool)0;
	}
}
// Method Definition Index: 30046
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_TryReadUIntValue_mCAB5614B9AEEE9E4B48820EC8F9E91CB17DE5F18_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, uint32_t* ___0_value, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:166>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0028;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_tD73AC74B29139087A83959CB3395A0580A2128AE L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0((&L_4), L_3, InputFeatureUsage_1__ctor_m60EAD5DA963ED229B922EBAAEF0D226796B5CEC0_RuntimeMethod_var);
		uint32_t* L_5 = ___0_value;
		bool L_6;
		L_6 = InputDevice_TryGetFeatureValue_m9FC969BEFF0E5BAB78DD9F2130F437788D20068C(L_1, L_4, L_5, NULL);
		if (!L_6)
		{
			goto IL_0028;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:167>
		return (bool)1;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:169>
		uint32_t* L_7 = ___0_value;
		*((int32_t*)L_7) = (int32_t)0;
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:170>
		return (bool)0;
	}
}
// Method Definition Index: 30047
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_TryReadFloatValue_m014F713899E4DC5B4F178634B5505856C1829F03_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, float* ___0_value, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:180>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0028;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t311D0F42F1A7BF37D3CEAC15A53A1F24165F1848 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989((&L_4), L_3, InputFeatureUsage_1__ctor_m6357AF3E3C16046E807776AA58473ABC83F88989_RuntimeMethod_var);
		float* L_5 = ___0_value;
		bool L_6;
		L_6 = InputDevice_TryGetFeatureValue_m675D52240379FEF80D6499B5031941812FDFD081(L_1, L_4, L_5, NULL);
		if (!L_6)
		{
			goto IL_0028;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:181>
		return (bool)1;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:183>
		float* L_7 = ___0_value;
		*((float*)L_7) = (float)(0.0f);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:184>
		return (bool)0;
	}
}
// Method Definition Index: 30048
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_TryReadVector2Value_mCC4A8B07339DC801FE7FDCEE188B52C36FB7B642_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7* ___0_value, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:194>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0028;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_tEB160A05BCDCCA4F96072CBA0866498D06B9A27C L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A((&L_4), L_3, InputFeatureUsage_1__ctor_m502985516521824A155A5780090765043843868A_RuntimeMethod_var);
		Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7* L_5 = ___0_value;
		bool L_6;
		L_6 = InputDevice_TryGetFeatureValue_mB2C15D1FC747DA9FB5958FA17E77049886FB3BBA(L_1, L_4, L_5, NULL);
		if (!L_6)
		{
			goto IL_0028;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:195>
		return (bool)1;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:197>
		Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7* L_7 = ___0_value;
		il2cpp_codegen_initobj(L_7, sizeof(Vector2_t1FD6F485C871E832B347AB2DC8CBA08B739D8DF7));
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:198>
		return (bool)0;
	}
}
// Method Definition Index: 30049
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_TryReadVector3Value_m9276C72F191B6C43100BABDF25B9FF8D3A55FFB8_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2* ___0_value, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:208>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0028;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t2E901FA41650EB29399194768CAA93D477CEBC58 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA((&L_4), L_3, InputFeatureUsage_1__ctor_m4267CE5D9D4C8FFE0CD48B585565A9DCADFB4FDA_RuntimeMethod_var);
		Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2* L_5 = ___0_value;
		bool L_6;
		L_6 = InputDevice_TryGetFeatureValue_m472B5ECE996FB7440CACCF1E85722DA4963E3167(L_1, L_4, L_5, NULL);
		if (!L_6)
		{
			goto IL_0028;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:209>
		return (bool)1;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:211>
		Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2* L_7 = ___0_value;
		il2cpp_codegen_initobj(L_7, sizeof(Vector3_t24C512C7B96BBABAD472002D0BA2BDA40A5A80B2));
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:212>
		return (bool)0;
	}
}
// Method Definition Index: 30050
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_TryReadQuaternionValue_m59D008BC51086009D727F31D3FEC2BA0A50F12C6_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974* ___0_value, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:222>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0028;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t8489CEC68B1EC178F2634079A9D7CD9E90D3CF5D L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08((&L_4), L_3, InputFeatureUsage_1__ctor_m14B4290F5C2B58B777726B4079A7CC2238176A08_RuntimeMethod_var);
		Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974* L_5 = ___0_value;
		bool L_6;
		L_6 = InputDevice_TryGetFeatureValue_m0C1A9761DD0D1C6D1EF4BAB2FAF1BC1A9541BB9F(L_1, L_4, L_5, NULL);
		if (!L_6)
		{
			goto IL_0028;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:223>
		return (bool)1;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:225>
		Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974* L_7 = ___0_value;
		il2cpp_codegen_initobj(L_7, sizeof(Quaternion_tDA59F214EF07D7700B26E40E562F267AF7306974));
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:226>
		return (bool)0;
	}
}
// Method Definition Index: 30051
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_TryReadInputTrackingStateValue_m7AF90DA8A391B6E94FF034B82895151AC86B7510_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, uint32_t* ___0_value, const RuntimeMethod* method) 
{
	static bool s_Il2CppMethodInitialized;
	if (!s_Il2CppMethodInitialized)
	{
		il2cpp_codegen_initialize_runtime_metadata((uintptr_t*)&InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55_RuntimeMethod_var);
		s_Il2CppMethodInitialized = true;
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:236>
		bool L_0;
		L_0 = XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 2));
		if (!L_0)
		{
			goto IL_0028;
		}
	}
	{
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_1 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* L_2 = __this->___m_Usage;
		NullCheck(L_2);
		String_t* L_3;
		L_3 = InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_inline(L_2, il2cpp_rgctx_method(method->klass->rgctx_data, 3));
		InputFeatureUsage_1_t4EF7DDCAC35EE23BA72694AC2AB76CF4A879FFD9 L_4;
		memset((&L_4), 0, sizeof(L_4));
		InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55((&L_4), L_3, InputFeatureUsage_1__ctor_m1E28CCD8989B0D08CD06B2E6200A55C33BC17A55_RuntimeMethod_var);
		uint32_t* L_5 = ___0_value;
		bool L_6;
		L_6 = InputDevice_TryGetFeatureValue_m8A01F07356DC85042F6BB7C6258A75C3EC3C4E11(L_1, L_4, L_5, NULL);
		if (!L_6)
		{
			goto IL_0028;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:237>
		return (bool)1;
	}

IL_0028:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:239>
		uint32_t* L_7 = ___0_value;
		*((int32_t*)L_7) = (int32_t)0;
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:240>
		return (bool)0;
	}
}
// Method Definition Index: 30052
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputDeviceValueReader_1_RefreshInputDeviceIfNeeded_mBAADB5F994FD363E73F0726B33982ABD8B20DD5E_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputDeviceValueReader.cs:250>
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_0 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		bool L_1;
		L_1 = InputDevice_get_isValid_mA908CF8195CECA44FF457430AFF9198C3FEC0948(L_0, NULL);
		if (L_1)
		{
			goto IL_001f;
		}
	}
	{
		uint32_t L_2 = ((XRInputDeviceValueReader_t91D732DACFC1260DE12B5C0EA0CE33B0EAF2581A*)__this)->___m_Characteristics;
		InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD* L_3 = (InputDevice_t882EE3EE8A71D8F5F38BA3F9356A49F24510E8BD*)(&__this->___m_InputDevice);
		bool L_4;
		L_4 = XRInputTrackingAggregator_TryGetDeviceWithExactCharacteristics_mECEA5AB0B5B089CD481FC654BA081484A967647A(L_2, L_3, NULL);
		return L_4;
	}

IL_001f:
	{
		return (bool)1;
	}
}
// Method Definition Index: 30053
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputDeviceValueReader_1__ctor_m929C31C577420C9309DE19085BDCE628C50368F7_gshared (XRInputDeviceValueReader_1_t52E057CBAAA0881CC1C329522294D1F15523C9C1* __this, const RuntimeMethod* method) 
{
	{
		XRInputDeviceValueReader__ctor_m5F34B83F8DA1BD97773ED8301A966D2E2891F757((XRInputDeviceValueReader_t91D732DACFC1260DE12B5C0EA0CE33B0EAF2581A*)__this, NULL);
		return;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winvalid-offsetof"
#pragma clang diagnostic ignored "-Wunused-variable"
#endif
// Method Definition Index: 30078
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1_get_manualValue_m6580D9D0E90768453554EC4C3F3A8BDE118832AD_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 1));
	const Il2CppFullySharedGenericStruct L_0 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:227>
		il2cpp_codegen_memcpy(L_0, il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),1)), SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_0, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}
}
// Method Definition Index: 30079
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1_set_manualValue_m7DE8FBB1F992F66B64970AE99224524E22F8232B_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, Il2CppFullySharedGenericStruct ___0_value, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 1));
	const Il2CppFullySharedGenericStruct L_0 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:228>
		il2cpp_codegen_memcpy(L_0, ___0_value, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_write_instance_field_data(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),1), L_0, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}
}
// Method Definition Index: 30080
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:234>
		RuntimeObject* L_0 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),2));
		return L_0;
	}
}
// Method Definition Index: 30081
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1_set_bypass_m391756331BB534D08D3C6DF2D5615F75B5E0E21E_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, RuntimeObject* ___0_value, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:234>
		RuntimeObject* L_0 = ___0_value;
		il2cpp_codegen_write_instance_field_data<RuntimeObject*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),2), L_0);
		return;
	}
}
// Method Definition Index: 30082
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1__ctor_mC3F4DB0A46B3C8AE8E07B03FDE9B6AC8D81E1C78_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:243>
		UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D* L_0 = (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		UnityObjectReferenceCache_2__ctor_mF3CC554EC436AA061C6D2F3D93C5ECD2D33FC91E(L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 4));
		il2cpp_codegen_write_instance_field_data<UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),4), L_0);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:248>
		XRInputValueReader__ctor_mF80B938FCE31DD85F0E3048DC60D969C2E50A296((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this, NULL);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:250>
		return;
	}
}
// Method Definition Index: 30083
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1__ctor_m8A6FE1E7C460CBD4EC6AE392547F9B5454503EFE_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, String_t* ___0_name, int32_t ___1_inputSourceMode, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:243>
		UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D* L_0 = (UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D*)il2cpp_codegen_object_new(il2cpp_rgctx_data(method->klass->rgctx_data, 3));
		UnityObjectReferenceCache_2__ctor_mF3CC554EC436AA061C6D2F3D93C5ECD2D33FC91E(L_0, il2cpp_rgctx_method(method->klass->rgctx_data, 4));
		il2cpp_codegen_write_instance_field_data<UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D*>(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),4), L_0);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:258>
		RuntimeTypeHandle_t332A452B8B6179E4469B69525D0FE82A88030F7B L_1 = { reinterpret_cast<intptr_t> (il2cpp_rgctx_type(method->klass->rgctx_data, 5)) };
		il2cpp_codegen_runtime_class_init_inline(il2cpp_defaults.systemtype_class);
		Type_t* L_2;
		L_2 = Type_GetTypeFromHandle_m6062B81682F79A4D6DF2640692EE6D9987858C57(L_1, NULL);
		String_t* L_3 = ___0_name;
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_4;
		L_4 = InputActionUtility_CreateValueAction_mF7C1DCF322EBC2C0478B2F0502AF265CBC570032(L_2, L_3, NULL);
		int32_t L_5 = ___1_inputSourceMode;
		XRInputValueReader__ctor_mAFED8EF378777B7CB3C92AE4ED4FE6130C2A2A6F((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this, L_4, L_5, NULL);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:260>
		return;
	}
}
// Method Definition Index: 30084
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR RuntimeObject* XRInputValueReader_1_GetObjectReference_m3BED8195FBDCE6A99FCC116EBDC1EB0D62D2A039_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:269>
		UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D* L_0 = *(UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),4));
		Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C* L_1 = *(Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),0));
		NullCheck(L_0);
		RuntimeObject* L_2;
		L_2 = UnityObjectReferenceCache_2_Get_mB6216FA3FF646BEC3525A47E5BADC61CE380DB8E(L_0, L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 6));
		return L_2;
	}
}
// Method Definition Index: 30085
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1_SetObjectReference_m862D31846AB537F3363F51ACE9942E1FD7A486F1_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, RuntimeObject* ___0_value, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:282>
		UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D* L_0 = *(UnityObjectReferenceCache_2_t850C1C23A747C1AB952CAB8328E7C55937432A4D**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),4));
		RuntimeObject* L_1 = ___0_value;
		NullCheck(L_0);
		UnityObjectReferenceCache_2_Set_mB32C421F461C529EEB9C7A74C95AC57CB41A44DF(L_0, (((Object_tC12DECB6760A7F2CBF65D9DCF18D044C2D97152C**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),0)))), L_1, il2cpp_rgctx_method(method->klass->rgctx_data, 7));
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:283>
		return;
	}
}
// Method Definition Index: 30086
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1_ReadValue_mFB37AAAB53CB16F2EEA26BCDF3A0023969C5A554_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 1));
	const Il2CppFullySharedGenericStruct L_3 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	const Il2CppFullySharedGenericStruct L_6 = L_3;
	const Il2CppFullySharedGenericStruct L_8 = L_3;
	const Il2CppFullySharedGenericStruct L_10 = L_3;
	const Il2CppFullySharedGenericStruct L_13 = L_3;
	const Il2CppFullySharedGenericStruct L_16 = L_3;
	const Il2CppFullySharedGenericStruct L_17 = L_3;
	const Il2CppFullySharedGenericStruct L_18 = L_3;
	const Il2CppFullySharedGenericStruct L_19 = L_3;
	BypassScope_t801793A02437762F196198D282A1980396D8B968 V_0;
	memset((&V_0), 0, sizeof(V_0));
	Il2CppFullySharedGenericStruct V_1 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	memset(V_1, 0, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1* V_2 = NULL;
	int32_t V_3 = 0;
	Il2CppFullySharedGenericStruct V_4 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	memset(V_4, 0, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	RuntimeObject* G_B13_0 = NULL;
	RuntimeObject* G_B12_0 = NULL;
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:288>
		RuntimeObject* L_0;
		L_0 = XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_inline(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
		if (!L_0)
		{
			goto IL_0037;
		}
	}
	{
		bool L_1 = *(bool*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),3));
		if (L_1)
		{
			goto IL_0037;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:290>
		BypassScope__ctor_mAFDCC84D1B05DD11FE45CA5C33454771613E01D5((&V_0), __this, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
	}
	{
		auto __finallyBlock = il2cpp::utils::Finally([&]
		{

FINALLY_0029:
			{
				BypassScope_Dispose_mD2092263EF1CD137EB35D092B66915B2A0EFDE40((&V_0), il2cpp_rgctx_method(method->klass->rgctx_data, 13));
				return;
			}
		});
		try
		{
			//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:292>
			RuntimeObject* L_2;
			L_2 = XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_inline(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
			NullCheck(L_2);
			InterfaceActionInvoker1Invoker< Il2CppFullySharedGenericStruct* >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 2), L_2, (Il2CppFullySharedGenericStruct*)L_3);
			il2cpp_codegen_memcpy(V_1, L_3, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
			goto IL_00b2;
		}
		catch(Il2CppExceptionWrapper& e)
		{
			__finallyBlock.StoreException(e.ex);
		}
	}

IL_0037:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:296>
		int32_t L_4 = ((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this)->___m_InputSourceMode;
		V_3 = L_4;
		int32_t L_5 = V_3;
		switch (L_5)
		{
			case 0:
			{
				goto IL_0058;
			}
			case 1:
			{
				goto IL_0063;
			}
			case 2:
			{
				goto IL_006f;
			}
			case 3:
			{
				goto IL_0090;
			}
			case 4:
			{
				goto IL_00ab;
			}
		}
	}

IL_0058:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:300>
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_4, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(L_6, V_4, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_6, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_0063:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:303>
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_7 = ((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this)->___m_InputAction;
		XRInputValueReader_1_ReadValue_mA9DD9A98276A883692B7BCBDFBAB6912D60F41E9(L_7, (Il2CppFullySharedGenericStruct*)L_8, il2cpp_rgctx_method(method->klass->rgctx_data, 14));
		il2cpp_codegen_memcpy(il2cppRetVal, L_8, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_006f:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:306>
		NullCheck((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this);
		bool L_9;
		L_9 = XRInputValueReader_TryGetInputActionReference_mD39365C3DCD6A92BCCD9918EF4919D075CF17806((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this, (&V_2), NULL);
		if (L_9)
		{
			goto IL_0084;
		}
	}
	{
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_4, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(L_10, V_4, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_10, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_0084:
	{
		InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1* L_11 = V_2;
		NullCheck(L_11);
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_12;
		L_12 = InputActionReference_get_action_m395EDEA6A93B54555D22323FDA6E1B1E931CE6EF(L_11, NULL);
		XRInputValueReader_1_ReadValue_mA9DD9A98276A883692B7BCBDFBAB6912D60F41E9(L_12, (Il2CppFullySharedGenericStruct*)L_13, il2cpp_rgctx_method(method->klass->rgctx_data, 14));
		il2cpp_codegen_memcpy(il2cppRetVal, L_13, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_0090:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:310>
		RuntimeObject* L_14;
		L_14 = XRInputValueReader_1_GetObjectReference_m3BED8195FBDCE6A99FCC116EBDC1EB0D62D2A039(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 16));
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:311>
		RuntimeObject* L_15 = L_14;
		if (L_15)
		{
			G_B13_0 = L_15;
			goto IL_00a5;
		}
		G_B12_0 = L_15;
	}
	{
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_4, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(L_16, V_4, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_16, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_00a5:
	{
		NullCheck(G_B13_0);
		InterfaceActionInvoker1Invoker< Il2CppFullySharedGenericStruct* >::Invoke(0, il2cpp_rgctx_data(method->klass->rgctx_data, 2), G_B13_0, (Il2CppFullySharedGenericStruct*)L_17);
		il2cpp_codegen_memcpy(il2cppRetVal, L_17, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_00ab:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:315>
		il2cpp_codegen_memcpy(L_18, il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),1)), SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_18, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_00b2:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:317>
		il2cpp_codegen_memcpy(L_19, V_1, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_19, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}
}
// Method Definition Index: 30087
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputValueReader_1_TryReadValue_mC84F19E640053D49DF7AC4E26440A3649D928CD4_gshared (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, Il2CppFullySharedGenericStruct* ___0_value, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 1));
	const Il2CppFullySharedGenericStruct L_24 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	BypassScope_t801793A02437762F196198D282A1980396D8B968 V_0;
	memset((&V_0), 0, sizeof(V_0));
	bool V_1 = false;
	InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1* V_2 = NULL;
	int32_t V_3 = 0;
	RuntimeObject* V_4 = NULL;
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:322>
		RuntimeObject* L_0;
		L_0 = XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_inline(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
		if (!L_0)
		{
			goto IL_0038;
		}
	}
	{
		bool L_1 = *(bool*)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),3));
		if (L_1)
		{
			goto IL_0038;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:324>
		BypassScope__ctor_mAFDCC84D1B05DD11FE45CA5C33454771613E01D5((&V_0), __this, il2cpp_rgctx_method(method->klass->rgctx_data, 9));
	}
	{
		auto __finallyBlock = il2cpp::utils::Finally([&]
		{

FINALLY_002a:
			{
				BypassScope_Dispose_mD2092263EF1CD137EB35D092B66915B2A0EFDE40((&V_0), il2cpp_rgctx_method(method->klass->rgctx_data, 13));
				return;
			}
		});
		try
		{
			//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:326>
			RuntimeObject* L_2;
			L_2 = XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_inline(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 8));
			Il2CppFullySharedGenericStruct* L_3 = ___0_value;
			NullCheck(L_2);
			bool L_4;
			L_4 = InterfaceFuncInvoker1< bool, Il2CppFullySharedGenericStruct* >::Invoke(1, il2cpp_rgctx_data(method->klass->rgctx_data, 2), L_2, L_3);
			V_1 = L_4;
			goto IL_00bb;
		}
		catch(Il2CppExceptionWrapper& e)
		{
			__finallyBlock.StoreException(e.ex);
		}
	}

IL_0038:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:330>
		NullCheck((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this);
		int32_t L_5;
		L_5 = XRInputValueReader_get_inputSourceMode_m6D12A254104BBE6F3945ACFE6CAC42DC51CDD5E0_inline((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this, NULL);
		V_3 = L_5;
		int32_t L_6 = V_3;
		switch (L_6)
		{
			case 0:
			{
				goto IL_0059;
			}
			case 1:
			{
				goto IL_0062;
			}
			case 2:
			{
				goto IL_006f;
			}
			case 3:
			{
				goto IL_008f;
			}
			case 4:
			{
				goto IL_00ad;
			}
		}
	}

IL_0059:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:334>
		Il2CppFullySharedGenericStruct* L_7 = ___0_value;
		il2cpp_codegen_initobj(L_7, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:335>
		return (bool)0;
	}

IL_0062:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:338>
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_8 = ((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this)->___m_InputAction;
		Il2CppFullySharedGenericStruct* L_9 = ___0_value;
		bool L_10;
		L_10 = XRInputValueReader_1_TryReadValue_mAF814AE91F21FF5F3AD73616B7D14DB1CAD004D6(L_8, L_9, il2cpp_rgctx_method(method->klass->rgctx_data, 19));
		return L_10;
	}

IL_006f:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:341>
		NullCheck((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this);
		bool L_11;
		L_11 = XRInputValueReader_TryGetInputActionReference_mD39365C3DCD6A92BCCD9918EF4919D075CF17806((XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59*)__this, (&V_2), NULL);
		if (!L_11)
		{
			goto IL_0086;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:342>
		InputActionReference_t64730C6B41271E0983FC21BFB416169F5D6BC4A1* L_12 = V_2;
		NullCheck(L_12);
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_13;
		L_13 = InputActionReference_get_action_m395EDEA6A93B54555D22323FDA6E1B1E931CE6EF(L_12, NULL);
		Il2CppFullySharedGenericStruct* L_14 = ___0_value;
		bool L_15;
		L_15 = XRInputValueReader_1_TryReadValue_mAF814AE91F21FF5F3AD73616B7D14DB1CAD004D6(L_13, L_14, il2cpp_rgctx_method(method->klass->rgctx_data, 19));
		return L_15;
	}

IL_0086:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:344>
		Il2CppFullySharedGenericStruct* L_16 = ___0_value;
		il2cpp_codegen_initobj(L_16, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:345>
		return (bool)0;
	}

IL_008f:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:349>
		RuntimeObject* L_17;
		L_17 = XRInputValueReader_1_GetObjectReference_m3BED8195FBDCE6A99FCC116EBDC1EB0D62D2A039(__this, il2cpp_rgctx_method(method->klass->rgctx_data, 16));
		V_4 = L_17;
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:350>
		RuntimeObject* L_18 = V_4;
		if (!L_18)
		{
			goto IL_00a4;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:351>
		RuntimeObject* L_19 = V_4;
		Il2CppFullySharedGenericStruct* L_20 = ___0_value;
		NullCheck(L_19);
		bool L_21;
		L_21 = InterfaceFuncInvoker1< bool, Il2CppFullySharedGenericStruct* >::Invoke(1, il2cpp_rgctx_data(method->klass->rgctx_data, 2), L_19, L_20);
		return L_21;
	}

IL_00a4:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:353>
		Il2CppFullySharedGenericStruct* L_22 = ___0_value;
		il2cpp_codegen_initobj(L_22, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:354>
		return (bool)0;
	}

IL_00ad:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:358>
		Il2CppFullySharedGenericStruct* L_23 = ___0_value;
		il2cpp_codegen_memcpy(L_24, il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),1)), SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericStruct*)L_23, L_24, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(method->klass->rgctx_data, 1), (void**)(Il2CppFullySharedGenericStruct*)L_23, (void*)L_24);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:359>
		return (bool)1;
	}

IL_00bb:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:361>
		bool L_25 = V_1;
		return L_25;
	}
}
// Method Definition Index: 30088
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR void XRInputValueReader_1_ReadValue_mA9DD9A98276A883692B7BCBDFBAB6912D60F41E9_gshared (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___0_action, Il2CppFullySharedGenericStruct* il2cppRetVal, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(InitializedTypeInfo(method->klass)->rgctx_data, 1));
	const Il2CppFullySharedGenericStruct L_1 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	const Il2CppFullySharedGenericStruct L_3 = L_1;
	Il2CppFullySharedGenericStruct V_0 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	memset(V_0, 0, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:365>
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_0 = ___0_action;
		if (L_0)
		{
			goto IL_000d;
		}
	}
	{
		il2cpp_codegen_initobj((Il2CppFullySharedGenericStruct*)V_0, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(L_1, V_0, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		il2cpp_codegen_memcpy(il2cppRetVal, L_1, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}

IL_000d:
	{
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_2 = ___0_action;
		NullCheck(L_2);
		InputAction_ReadValue_TisIl2CppFullySharedGenericStruct_m0B8C6490DD8EE673339E603898F5BB14254C3DBD(L_2, (Il2CppFullySharedGenericStruct*)L_3, il2cpp_rgctx_method(InitializedTypeInfo(method->klass)->rgctx_data, 20));
		il2cpp_codegen_memcpy(il2cppRetVal, L_3, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		return;
	}
}
// Method Definition Index: 30089
IL2CPP_EXTERN_C IL2CPP_METHOD_ATTR bool XRInputValueReader_1_TryReadValue_mAF814AE91F21FF5F3AD73616B7D14DB1CAD004D6_gshared (InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* ___0_action, Il2CppFullySharedGenericStruct* ___1_value, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(InitializedTypeInfo(method->klass)->rgctx_data, 1));
	const Il2CppFullySharedGenericStruct L_4 = alloca(SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:370>
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_0 = ___0_action;
		if (L_0)
		{
			goto IL_000c;
		}
	}
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:372>
		Il2CppFullySharedGenericStruct* L_1 = ___1_value;
		il2cpp_codegen_initobj(L_1, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:373>
		return (bool)0;
	}

IL_000c:
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:376>
		Il2CppFullySharedGenericStruct* L_2 = ___1_value;
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_3 = ___0_action;
		NullCheck(L_3);
		InputAction_ReadValue_TisIl2CppFullySharedGenericStruct_m0B8C6490DD8EE673339E603898F5BB14254C3DBD(L_3, (Il2CppFullySharedGenericStruct*)L_4, il2cpp_rgctx_method(InitializedTypeInfo(method->klass)->rgctx_data, 20));
		il2cpp_codegen_memcpy((Il2CppFullySharedGenericStruct*)L_2, L_4, SizeOf_TValue_t760FA50A2A343274E5B6CD6587214C08E253F2B7);
		Il2CppCodeGenWriteBarrierForClass(il2cpp_rgctx_data(InitializedTypeInfo(method->klass)->rgctx_data, 1), (void**)(Il2CppFullySharedGenericStruct*)L_2, (void*)L_4);
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:377>
		InputAction_t1B550AD2B55AF322AFB53CD28DA64081220D01CD* L_5 = ___0_action;
		NullCheck(L_5);
		bool L_6;
		L_6 = InputAction_IsInProgress_m0572B3C5AA6C8E7FC4A1927DDAA54C3D40714E62(L_5, NULL);
		return L_6;
	}
}
#ifdef __clang__
#pragma clang diagnostic pop
#endif
// Method Definition Index: 702
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t String_get_Length_m42625D67623FA5CC7A44D47425CE86FB946542D2_inline (String_t* __this, const RuntimeMethod* method) 
{
	{
		int32_t L_0 = __this->____stringLength;
		return L_0;
	}
}
// Method Definition Index: 30067
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t XRInputValueReader_get_inputSourceMode_m6D12A254104BBE6F3945ACFE6CAC42DC51CDD5E0_inline (XRInputValueReader_t0A220D04F7D6F5BC7E5A253F5AF8A9C3AB430D59* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:107>
		int32_t L_0 = __this->___m_InputSourceMode;
		return L_0;
	}
}
// Method Definition Index: 4901
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* TaskCompletionSource_1_get_Task_m4994989AA2174905CF517397D0F6B082ADC29EE9_gshared_inline (TaskCompletionSource_1_t8A40BE53A167B6D71D5640881A7A894D8DA94970* __this, const RuntimeMethod* method) 
{
	{
		Task_1_tDF1FF540D7D2248A08580387A39717B7FB7A9CF9* L_0 = __this->____task;
		return L_0;
	}
}
// Method Definition Index: 62155
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* Result_get_Error_mA9CAACBF365B2B74E821767A0713ADA11148EC69_gshared_inline (Result_t3B46D8CB111F11A3E1274C22D61B9130725BEE93* __this, const RuntimeMethod* method) 
{
	{
		ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757* L_0 = *(ExceptionDispatchInfo_tD7AF19E75FEC22F4A8329FD1E9EDF96615CB2757**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),1));
		return L_0;
	}
}
// Method Definition Index: 898
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Func_2_Invoke_m31CAC166FDC80DC5AE52A5AEFFEE2D9B27A1CA3F_gshared_inline (Func_2_t7F5F5324CE2DDB7001B68FFE29A5D9F907139FB0* __this, Il2CppFullySharedGenericAny ___0_arg, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) 
{
	typedef void (*FunctionPointerType) (RuntimeObject*, Il2CppFullySharedGenericAny, Il2CppFullySharedGenericAny*, const RuntimeMethod*);
	((FunctionPointerType)__this->___invoke_impl)((Il2CppObject*)__this->___method_code, ___0_arg, il2cppRetVal, reinterpret_cast<RuntimeMethod*>(__this->___method));
}
// Method Definition Index: 11369
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR void Enumerator_get_Current_m8B42D4B2DE853B9D11B997120CD0228D4780E394_gshared_inline (Enumerator_tF5AC6CD19D283FBD724440520CEE68FE2602F7AF* __this, Il2CppFullySharedGenericAny* il2cppRetVal, const RuntimeMethod* method) 
{
	const uint32_t SizeOf_T_t010616E3077234188F9BB4FAF369F8571BC5F2E1 = il2cpp_codegen_sizeof(il2cpp_rgctx_data_no_init(InitializedTypeInfo(method->klass)->rgctx_data, 2));
	const Il2CppFullySharedGenericAny L_0 = alloca(SizeOf_T_t010616E3077234188F9BB4FAF369F8571BC5F2E1);
	{
		il2cpp_codegen_memcpy(L_0, il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(InitializedTypeInfo(method->klass)->rgctx_data, 1),3)), SizeOf_T_t010616E3077234188F9BB4FAF369F8571BC5F2E1);
		il2cpp_codegen_memcpy(il2cppRetVal, L_0, SizeOf_T_t010616E3077234188F9BB4FAF369F8571BC5F2E1);
		return;
	}
}
// Method Definition Index: 56319
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR int32_t WorkSlice_1_get_length_m7212817506EACBA1AB0D914DE401C6FA05F0DD9D_gshared_inline (WorkSlice_1_t95249C8534D20AFEA3985723537EDE6E5BF06809* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.render-pipelines.universal@ba467ec059b9/Runtime/LightCookieManager.cs:124>
		int32_t L_0 = __this->___m_Length;
		return L_0;
	}
}
// Method Definition Index: 112907
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR String_t* ExtractKeyDelegate_Invoke_m299616CF7575CD317723CE89D3BA8B8F04A9B722_gshared_inline (ExtractKeyDelegate_t0FCB0690B76E40F52DC9D05708A8FC488624E3CD* __this, Il2CppFullySharedGenericAny ___0_value, const RuntimeMethod* method) 
{
	typedef String_t* (*FunctionPointerType) (RuntimeObject*, Il2CppFullySharedGenericAny, const RuntimeMethod*);
	return ((FunctionPointerType)__this->___invoke_impl)((Il2CppObject*)__this->___method_code, ___0_value, reinterpret_cast<RuntimeMethod*>(__this->___method));
}
// Method Definition Index: 29955
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR String_t* InputFeatureUsageString_1_get_name_m26AEFAF1CEE0F05D4FEBFD32AAA358D234BB2F6C_gshared_inline (InputFeatureUsageString_1_tED5559980FF0D037F1720B535BE2F33E44336CBB* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/InputFeatureUsageString.cs:21>
		String_t* L_0 = __this->___m_Name;
		return L_0;
	}
}
// Method Definition Index: 30080
IL2CPP_MANAGED_FORCE_INLINE IL2CPP_METHOD_ATTR RuntimeObject* XRInputValueReader_1_get_bypass_m86D6EE8C2B6C04E222D96122A85F792D9A7B8CAB_gshared_inline (XRInputValueReader_1_t10FA1318595127FAFC306218EEA119C7F8DF1B5F* __this, const RuntimeMethod* method) 
{
	{
		//<source_info:./Library/PackageCache/com.unity.xr.interaction.toolkit@7faefd988174/Runtime/Inputs/Readers/XRInputValueReader.cs:234>
		RuntimeObject* L_0 = *(RuntimeObject**)il2cpp_codegen_get_instance_field_data_pointer(__this, il2cpp_rgctx_field(il2cpp_rgctx_data_no_init(method->klass->rgctx_data, 0),2));
		return L_0;
	}
}
