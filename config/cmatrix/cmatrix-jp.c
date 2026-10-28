/*
 * cmatrix-jp.c — Matrix Code Rain en Japonés (Katakana) con TrueColor 24-bit
 * Estilo por defecto: Azul Neón Intenso con fondo transparente para tmux/terminal.
 *
 * Compilación:
 *   gcc -O2 -Wall -Wextra -o ~/.local/bin/cmatrix config/cmatrix/cmatrix-jp.c
 */

#define _DEFAULT_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <getopt.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <termios.h>
#include <time.h>
#include <unistd.h>

/* Glifos japoneses (Katakana de medio ancho = 1 celda en terminal + dígitos/símbolos Matrix) */
static const char *JP_GLYPHS[] = {
    "ｱ", "ｲ", "ｳ", "ｴ", "ｵ", "ｶ", "ｷ", "ｸ", "ｹ", "ｺ",
    "ｻ", "ｼ", "ｽ", "ｾ", "ｿ", "ﾀ", "ﾁ", "ﾂ", "ﾃ", "ﾄ",
    "ﾅ", "ﾆ", "ﾇ", "ﾈ", "ﾉ", "ﾊ", "ﾋ", "ﾌ", "ﾍ", "ﾎ",
    "ﾏ", "ﾐ", "ﾑ", "ﾒ", "ﾓ", "ﾔ", "ﾕ", "ﾖ", "ﾗ", "ﾘ",
    "ﾙ", "ﾚ", "ﾛ", "ﾜ", "ﾝ", "ｦ", "ｧ", "ｨ", "ｩ", "ｪ",
    "ｫ", "ｬ", "ｭ", "ｮ", "ｯ", "ｰ", "0", "1", "2", "3",
    "4", "5", "7", "8", "9", "Z", ":", "=", "*", "+",
    "-", "<", ">", "¦"
};
#define NUM_JP_GLYPHS ((int)(sizeof(JP_GLYPHS) / sizeof(JP_GLYPHS[0])))

typedef struct {
    int r, g, b;
} RGB;

typedef enum {
    THEME_BLUE = 0,
    THEME_CYAN,
    THEME_MAGENTA,
    THEME_GREEN,
    THEME_RED,
    THEME_YELLOW,
    THEME_WHITE,
    THEME_COUNT
} ThemeId;

/* Paletas de 7 niveles: [0]=Cabeza brillante, [1]=Sub-cabeza neón, [2..6]=Degradado de estela */
static const RGB PALETTES[THEME_COUNT][7] = {
    /* THEME_BLUE: Azul Neón Intenso */
    [THEME_BLUE] = {
        {240, 249, 255}, /* Cabeza: Blanco hielo brillante (#f0f9ff) */
        { 56, 189, 248}, /* Sub-cabeza: Azul cielo neón (#38bdf8) */
        { 14, 165, 233}, /* Estela alta: Azul eléctrico (#0ea5e9) */
        {  2, 132, 199}, /* Estela media-alta (#0284c7) */
        { 37,  99, 235}, /* Estela media: Azul intenso (#2563eb) */
        { 29,  78, 216}, /* Estela baja (#1d4ed8) */
        { 30,  58, 138}  /* Cola profunda (#1e3a8a) */
    },
    /* THEME_CYAN */
    [THEME_CYAN] = {
        {236, 254, 255},
        {103, 232, 249},
        { 34, 211, 238},
        {  6, 182, 212},
        {  8, 145, 178},
        { 14, 116, 144},
        { 22,  78,  99}
    },
    /* THEME_MAGENTA */
    [THEME_MAGENTA] = {
        {250, 245, 255},
        {192, 132, 252},
        {168,  85, 247},
        {147,  51, 234},
        {124,  58, 237},
        {109,  40, 217},
        { 88,  28, 135}
    },
    /* THEME_GREEN */
    [THEME_GREEN] = {
        {240, 253, 244},
        { 74, 222, 128},
        { 34, 197,  94},
        { 22, 163,  74},
        { 21, 128,  61},
        { 22, 101,  52},
        { 20,  83,  45}
    },
    /* THEME_RED */
    [THEME_RED] = {
        {254, 242, 242},
        {248, 113, 113},
        {239,  68,  68},
        {220,  38,  38},
        {185,  28,  28},
        {153,  27,  27},
        {127,  29,  29}
    },
    /* THEME_YELLOW */
    [THEME_YELLOW] = {
        {254, 252, 232},
        {250, 204,  21},
        {234, 179,   8},
        {202, 138,   4},
        {161,  98,   7},
        {133,  77,  14},
        {113,  63,  18}
    },
    /* THEME_WHITE */
    [THEME_WHITE] = {
        {255, 255, 255},
        {226, 232, 240},
        {203, 213, 225},
        {148, 163, 184},
        {100, 116, 139},
        { 71,  85, 105},
        { 51,  65,  85}
    }
};

typedef struct {
    float head_y;
    float speed;
    int length;
    int *glyph_idx;
    ThemeId col_theme;
} Stream;

static struct termios orig_termios;
static bool term_initialized = false;
static volatile sig_atomic_t running = 1;
static volatile sig_atomic_t resized = 0;

static void restore_terminal(void) {
    if (term_initialized) {
        const char *reset_seq = "\033[0m\033[?25h\033[?1049l";
        if (write(STDOUT_FILENO, reset_seq, strlen(reset_seq)) < 0) {
            /* ignore */
        }
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig_termios);
        term_initialized = false;
    }
}

static void handle_sig(int sig) {
    (void)sig;
    running = 0;
}

static void handle_winch(int sig) {
    (void)sig;
    resized = 1;
}

static void get_term_size(int *rows, int *cols) {
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0 && ws.ws_row > 0 && ws.ws_col > 0) {
        *rows = ws.ws_row;
        *cols = ws.ws_col;
    } else {
        *rows = 24;
        *cols = 80;
    }
}

static ThemeId parse_color(const char *name) {
    if (!name) return THEME_BLUE;
    if (strcasecmp(name, "blue") == 0 || strcasecmp(name, "azul") == 0) return THEME_BLUE;
    if (strcasecmp(name, "cyan") == 0) return THEME_CYAN;
    if (strcasecmp(name, "magenta") == 0 || strcasecmp(name, "purple") == 0 || strcasecmp(name, "morado") == 0) return THEME_MAGENTA;
    if (strcasecmp(name, "green") == 0 || strcasecmp(name, "verde") == 0) return THEME_GREEN;
    if (strcasecmp(name, "red") == 0 || strcasecmp(name, "rojo") == 0) return THEME_RED;
    if (strcasecmp(name, "yellow") == 0 || strcasecmp(name, "amarillo") == 0) return THEME_YELLOW;
    if (strcasecmp(name, "white") == 0 || strcasecmp(name, "blanco") == 0) return THEME_WHITE;
    return THEME_BLUE;
}

static void print_usage(const char *prog) {
    printf("Uso: %s [-abBcfhlLnrosmxV] [-u delay] [-C color]\n", prog);
    printf("Matrix en japonés (Katakana) con color Azul Neón por defecto.\n\n");
    printf("Opciones:\n");
    printf("  -a          Scroll asíncrono (velocidades variables por columna, activo por defecto)\n");
    printf("  -b          Caracteres en negrita parciales (activo por defecto)\n");
    printf("  -B          Todos los caracteres en negrita\n");
    printf("  -n          Sin negrita\n");
    printf("  -c          Caracteres japoneses Katakana (activo por defecto)\n");
    printf("  -m          Modo Lambda (λ)\n");
    printf("  -r          Modo arcoíris\n");
    printf("  -s          Modo protector de pantalla (sale al presionar cualquier tecla)\n");
    printf("  -u [0-10]   Velocidad de actualización (por defecto: 4)\n");
    printf("  -C [color]  Color: blue (defecto), cyan, magenta, green, red, yellow, white\n");
    printf("  -h          Mostrar esta ayuda\n");
    printf("  -V          Mostrar versión\n");
}

static void init_stream(Stream *s, int rows, bool async_scroll, bool initial, ThemeId base_theme, bool rainbow) {
    int min_len = rows / 3;
    if (min_len < 6) min_len = 6;
    int max_len = rows + (rows / 2);
    if (max_len <= min_len) max_len = min_len + 8;

    s->length = min_len + (rand() % (max_len - min_len + 1));
    if (initial) {
        s->head_y = (float)(-(rand() % (rows * 2)));
    } else {
        s->head_y = (float)(-(rand() % (rows / 2 + 4)));
    }

    if (async_scroll) {
        s->speed = 0.45f + ((float)(rand() % 85) / 100.0f);
    } else {
        s->speed = 0.85f;
    }

    if (rainbow) {
        s->col_theme = (ThemeId)(rand() % THEME_COUNT);
    } else {
        s->col_theme = base_theme;
    }

    for (int r = 0; r < rows; r++) {
        s->glyph_idx[r] = rand() % NUM_JP_GLYPHS;
    }
}

int main(int argc, char **argv) {
    bool async_scroll = true;
    int bold_mode = 1; /* 0 = none, 1 = partial, 2 = all */
    bool screensaver = false;
    bool rainbow = false;
    bool lambda_mode = false;
    int delay_level = 4;
    ThemeId theme = THEME_BLUE;

    int opt;
    while ((opt = getopt(argc, argv, "abBcfhlLnrosmxVu:C:")) != -1) {
        switch (opt) {
            case 'a': async_scroll = true; break;
            case 'b': bold_mode = 1; break;
            case 'B': bold_mode = 2; break;
            case 'n': bold_mode = 0; break;
            case 'c': /* Japonés activo por defecto */ break;
            case 'm': lambda_mode = true; break;
            case 'r': rainbow = true; break;
            case 's': screensaver = true; break;
            case 'u':
                delay_level = atoi(optarg);
                if (delay_level < 0) delay_level = 0;
                if (delay_level > 10) delay_level = 10;
                break;
            case 'C':
                theme = parse_color(optarg);
                break;
            case 'V':
                printf("cmatrix-jp 2.0 (Japanese Katakana + TrueColor Neon Blue Edition)\n");
                return 0;
            case 'h':
            default:
                print_usage(argv[0]);
                return (opt == 'h') ? 0 : 1;
        }
    }

    srand((unsigned int)(time(NULL) ^ getpid()));

    if (tcgetattr(STDIN_FILENO, &orig_termios) == 0) {
        struct termios raw = orig_termios;
        raw.c_lflag &= ~(ECHO | ICANON | ISIG);
        raw.c_iflag &= ~(IXON | ICRNL);
        raw.c_cc[VMIN] = 0;
        raw.c_cc[VTIME] = 0;
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
        term_initialized = true;
        atexit(restore_terminal);
    }

    signal(SIGINT, handle_sig);
    signal(SIGTERM, handle_sig);
    signal(SIGQUIT, handle_sig);
    signal(SIGWINCH, handle_winch);

    const char *init_seq = "\033[?1049h\033[?25l\033[49m\033[2J";
    if (write(STDOUT_FILENO, init_seq, strlen(init_seq)) < 0) {
        /* ignore */
    }

    int rows = 24, cols = 80;
    get_term_size(&rows, &cols);
    int num_streams = cols / 2;
    if (num_streams < 1) num_streams = 1;

    Stream *streams = calloc((size_t)num_streams, sizeof(Stream));
    for (int i = 0; i < num_streams; i++) {
        streams[i].glyph_idx = calloc((size_t)rows, sizeof(int));
        init_stream(&streams[i], rows, async_scroll, true, theme, rainbow);
    }

    size_t buf_cap = (size_t)rows * (size_t)cols * 48 + 4096;
    char *frame_buf = malloc(buf_cap);

    while (running) {
        if (resized) {
            resized = 0;
            for (int i = 0; i < num_streams; i++) {
                free(streams[i].glyph_idx);
            }
            free(streams);

            get_term_size(&rows, &cols);
            num_streams = cols / 2;
            if (num_streams < 1) num_streams = 1;

            streams = calloc((size_t)num_streams, sizeof(Stream));
            for (int i = 0; i < num_streams; i++) {
                streams[i].glyph_idx = calloc((size_t)rows, sizeof(int));
                init_stream(&streams[i], rows, async_scroll, true, theme, rainbow);
            }

            buf_cap = (size_t)rows * (size_t)cols * 48 + 4096;
            free(frame_buf);
            frame_buf = malloc(buf_cap);

            const char *clear_seq = "\033[49m\033[2J";
            if (write(STDOUT_FILENO, clear_seq, strlen(clear_seq)) < 0) {
                /* ignore */
            }
        }

        /* Leer teclado sin bloquear */
        unsigned char ch;
        if (read(STDIN_FILENO, &ch, 1) == 1) {
            if (screensaver || ch == 'q' || ch == 'Q' || ch == 3 || ch == 27) {
                break;
            }
            switch (ch) {
                case 'a': async_scroll = !async_scroll; break;
                case 'b': bold_mode = 1; break;
                case 'B': bold_mode = 2; break;
                case 'n': bold_mode = 0; break;
                case 'r': rainbow = !rainbow; break;
                case 'm': lambda_mode = !lambda_mode; break;
                case '!': theme = THEME_RED; rainbow = false; break;
                case '@': theme = THEME_GREEN; rainbow = false; break;
                case '#': theme = THEME_YELLOW; rainbow = false; break;
                case '$': theme = THEME_BLUE; rainbow = false; break;
                case '%': theme = THEME_MAGENTA; rainbow = false; break;
                case '^': theme = THEME_CYAN; rainbow = false; break;
                case '&': theme = THEME_WHITE; rainbow = false; break;
                default:
                    if (ch >= '0' && ch <= '9') {
                        delay_level = ch - '0';
                    }
                    break;
            }
        }

        /* Actualizar lluvia */
        for (int i = 0; i < num_streams; i++) {
            streams[i].head_y += streams[i].speed;
            int head_row = (int)streams[i].head_y;
            if (head_row >= 0 && head_row < rows) {
                streams[i].glyph_idx[head_row] = rand() % NUM_JP_GLYPHS;
            }
            /* Mutar ocasionalmente algún glifo activo para el efecto Matrix auténtico */
            int mut_row = rand() % rows;
            if (rand() % 3 == 0) {
                streams[i].glyph_idx[mut_row] = rand() % NUM_JP_GLYPHS;
            }
            if (head_row - streams[i].length > rows) {
                init_stream(&streams[i], rows, async_scroll, false, theme, rainbow);
            }
        }

        /* Construir frame completo con fondo transparente (\033[49m) */
        size_t pos = 0;
        pos += (size_t)snprintf(frame_buf + pos, buf_cap - pos, "\033[H\033[49m");

        for (int r = 0; r < rows; r++) {
            pos += (size_t)snprintf(frame_buf + pos, buf_cap - pos, "\033[%d;1H", r + 1);
            int prev_r = -1, prev_g = -1, prev_b = -1, prev_bold = -1;

            for (int i = 0; i < num_streams; i++) {
                int head_row = (int)streams[i].head_y;
                int dist = head_row - r;
                int len = streams[i].length;

                if (dist >= 0 && dist < len) {
                    ThemeId tid = rainbow ? streams[i].col_theme : theme;
                    int shade_idx;
                    if (dist == 0) {
                        shade_idx = 0; /* Cabeza blanca-hielo brillante */
                    } else if (dist <= 2) {
                        shade_idx = 1; /* Sub-cabeza azul cielo neón */
                    } else {
                        int rem = len - 3;
                        if (rem < 1) rem = 1;
                        shade_idx = 2 + ((dist - 3) * 5) / rem;
                        if (shade_idx > 6) shade_idx = 6;
                    }

                    RGB col = PALETTES[tid][shade_idx];
                    int use_bold = (bold_mode == 2) || (bold_mode == 1 && (dist <= 2 || (r + i) % 3 == 0));

                    if (col.r != prev_r || col.g != prev_g || col.b != prev_b || use_bold != prev_bold) {
                        pos += (size_t)snprintf(
                            frame_buf + pos,
                            buf_cap - pos,
                            "\033[%s;38;2;%d;%d;%dm",
                            use_bold ? "1" : "22",
                            col.r, col.g, col.b
                        );
                        prev_r = col.r;
                        prev_g = col.g;
                        prev_b = col.b;
                        prev_bold = use_bold;
                    }

                    const char *glyph = lambda_mode ? "λ" : JP_GLYPHS[streams[i].glyph_idx[r]];
                    pos += (size_t)snprintf(frame_buf + pos, buf_cap - pos, "%s ", glyph);
                } else {
                    pos += (size_t)snprintf(frame_buf + pos, buf_cap - pos, "  ");
                }
            }
        }

        if (write(STDOUT_FILENO, frame_buf, pos) < 0) {
            /* ignore */
        }

        int sleep_ms = 15 + delay_level * 12;
        struct timespec ts;
        ts.tv_sec = sleep_ms / 1000;
        ts.tv_nsec = (long)(sleep_ms % 1000) * 1000000L;
        nanosleep(&ts, NULL);
    }

    for (int i = 0; i < num_streams; i++) {
        free(streams[i].glyph_idx);
    }
    free(streams);
    free(frame_buf);
    restore_terminal();
    return 0;
}
