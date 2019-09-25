use std::{
    collections::HashMap,
    env,
    ffi::CString,
};

// Get the location of the executable. It will be in usr/bin somewhere
// Use at as basis for the ENV variable generation
// Remove bogus entities from the ENV list for a new process
// Start the new process with the new environment

pub fn get_appimage_directory() -> String {
    let current_exe = env::current_exe().expect("Failed to get path to current executable");
    let parent_path = current_exe.parent().and_then( |path| {
        path.parent()
    }).and_then( |path| {
        path.parent()
    }).expect("Failed to get the location of the AppImage");
    let mut path = String::new();
    path.push_str(parent_path.to_str().unwrap());
    return path;
}

pub fn create_new_environment() -> Vec<CString> {
    let mut environment = Environment {
        env: copy_environment(),
        root_dir: get_appimage_directory()
    };
    patch_path(&mut environment);
    convert_environment_to_cstrings(&environment)
}

struct Environment {
    env: HashMap<String, String>,
    root_dir: String,
}

const OS_ENV_PREFIX: &str = "OS_ENV_";

fn copy_environment() -> HashMap<String, String> {
    let mut environment = HashMap::new();
    for(key, value) in env::vars() {
        let os_key = format!("{}{}", OS_ENV_PREFIX, key);
        environment.insert(os_key, String::from(&value));
        environment.insert(key, value);
    }
    environment
}

fn patch_path(environment: &mut Environment) {
    let patch_key = String::from("PATH");
    let empty_value = String::from("");
    let cur_path = environment.env.get(&patch_key).unwrap_or(&empty_value);
    let new_value = format!("{appdir}/usr/bin/:{appdir}/usr/sbin/:{appdir}/usr/games/:{appdir}/bin/:{appdir}/sbin/:{cur_path}",
                            appdir = environment.root_dir, cur_path=cur_path);
    println!("{}", new_value);
    environment.env.insert(patch_key, new_value);
}

fn convert_environment_to_cstrings(environment: &Environment) -> Vec<CString> {
    let mut result = Vec::new();
    for (key, value) in &environment.env {
        let new_env = format!("{}={}", key, value);
        println!("{}", new_env);
        result.push(CString::new(new_env).unwrap());
    }
    result
}
