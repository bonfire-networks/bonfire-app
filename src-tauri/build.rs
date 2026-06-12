fn main() {
    // Work around rustc linking `-lclang_rt.ios` from a clang-version dir that
    // matches rustc's bundled LLVM (e.g. clang/17) rather than the installed
    // Xcode's (e.g. clang/21), which leaves the device build's dylib link with
    // "library 'clang_rt.ios' not found". Add the real resource dir — queried
    // from clang so it tracks Xcode upgrades — to the link search path.
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("ios") {
        if let Some(dir) = clang_runtime_dir() {
            println!("cargo:rustc-link-search=native={dir}");
        }
    }

    tauri_build::build()
}

/// `<clang resource dir>/lib/darwin`, where the compiler-rt static libs live.
fn clang_runtime_dir() -> Option<String> {
    let out = std::process::Command::new("clang")
        .arg("--print-resource-dir")
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let resource_dir = String::from_utf8(out.stdout).ok()?;
    Some(format!("{}/lib/darwin", resource_dir.trim()))
}
