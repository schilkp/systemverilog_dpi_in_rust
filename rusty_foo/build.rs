use std::env;
use std::path::PathBuf;

fn main() {
    let include_path = env::var("RUST_FOO_SVDPI_INCLUDE")
        .expect("RUST_FOO_SVDPI_INCLUDE environment variable not set");
    println!("cargo:rerun-if-env-changed=RUST_FOO_SVDPI_INCLUDE");
    println!("Using Verilator at: {}", include_path);

    let bindings = bindgen::Builder::default()
        .header("wrapper.h")
        .clang_arg(format!("-I{}", include_path))
        // Tell cargo to invalidate the built crate whenever any of the
        // included header files changed.
        .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
        .generate()
        .expect("Unable to generate bindings");

    let out_path = PathBuf::from(env::var("OUT_DIR").unwrap());
    bindings
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");

    println!("cargo:rerun-if-changed=src/dpi.rs");
    println!("cargo:rerun-if-changed=cbindgen.toml");
    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();
    cbindgen::Builder::new()
        .with_crate(crate_dir)
        .with_config(cbindgen::Config::from_file("cbindgen.toml").unwrap())
        .generate()
        .expect("Unable to generate C header")
        .write_to_file("target/my_rust_lib.h");
}
