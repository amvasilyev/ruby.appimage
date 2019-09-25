mod ext_process;

fn main() {
    let directory = ext_process::get_appimage_directory();
    ext_process::create_new_environment();
}
