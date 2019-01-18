/*    Bootloader
*    By : Misin Abdullah
*    Bootlader ya taulah
*/

#include <MisinX.S>  // assembly
#include <MisinX.h>  // C

/* Membuat Sector */
__sector CREATESECTOR new Loader as BootLoader;
if __00__ x86==WINAPI { // jika windows 10
    /* Mematikan semua jalan dan membiarkan
    *   System menginstall Driver dan membuat
    *   koneksi nya sendiri
    */
    System.Death(X_WINAPI){
        if __00__ x86 __NotAllow__ {
            try (LETSYSTEMDOHISJOBS){
                InitStansion(__MKA__);
            } Except {
                PRINT("[!] Tidak Bisa Memulai Booting! terjadi kesalahan");
            }
        } else {
            __remdar const continue __0x8886;
            __remdar __setcookies const continue __0x8273;
            __remdar __drivers const continue __0x87225;
        }
    }
}
