mod svdpi {
    #![allow(non_upper_case_globals)]
    #![allow(non_camel_case_types)]
    #![allow(dead_code)]
    include!(concat!(env!("OUT_DIR"), "/bindings.rs"));
}

#[unsafe(no_mangle)]
pub extern "C" fn foo_rs(input: *const svdpi::svLogicVecVal, out: *mut svdpi::svLogicVecVal) {
    // Null pointer checks
    if input.is_null() || out.is_null() {
        eprintln!("Error: Null pointer passed to foo()");
        return;
    }
    unsafe {
        let mut i: svdpi::svLogicVecVal = input.read();
        i.aval = (i.aval + 30) % 256;
        i.bval = 0;
        out.write(i);
    }
}
