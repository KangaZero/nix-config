from manim import *

LOGO_LINES = [
    "         .                  *.                                                        ",
    "       .*%0.                &&*.                                                      ",
    "     .*%%%00*               &&&&*.                                         .*.        ",
    "   .*%%%%%000*              &&&&&&*.                  ..*******.          .%@&'       ",
    " .*%%%%%%%00000             &&&&&&&&*.          .*0&%%@@@@@@@@@@@&0^      *@@@&'      ",
    "*00%%%%%%%000000.           &&&&&&&&&&*      o&@@@@%&00*^^^''''^^*0%&'  *@@@&         ",
    "0000%%%%%%0000000*          &&&&&&&&&&&    '%@@%0^ .*.          &%000&&&&@@@@&&&0o    ",
    "000000%%%%000000000.        &&&&&&&&&&&     0@*   0%@@0        *@@&&000%@@@0^^'       ",
    "0000000%%%0000000000*       &&&&&&&&&&&          00*@@0      *&@%'    0@@@0        *. ",
    "00000000%%000000000000      &&&&&&&&&&&         0 *@@%    .0%@@0'    0@@@0   *%&  &@%'",
    "000000000%'000000000000.    &&&&&&&&&&&        ^ 0@@%'  .o&@@&^     0@@@0   *@@& &@@0 ",
    "0000000000 '000000000000.   &&&&&&&&&&&       .*&@@%' .*0%@@&*'    *@@@0   *@@%  0@@* ",
    "0000000000   '00000000000*  &&&&&&&&&&&      *0%@@@%%%@@@%0^       *@@@0  *@@%  *%@@^ ",
    "0000000000    '000000000000.&&&&&&&&&&&      @@@@@@@@@@@%0'        '@@@& *@@%  &0%@@* ",
    "0000000000      000000000000%&&&&&&&&&&      0@@@^  '^00%@&o.      %@@%'*@@@'.&^0@@%  ",
    "0000000000       ^0000000000%%&&&&&&&&&     '@@%'      '0@@&'     &@@@' &@@@ 0&'@@@*  ",
    "0000000000        '000000000%%%%&&&&&&&    '@@%'         0@@@0   *@@@^ .@@@@&0  %@@%  ",
    "0000000000          00000000%%%%%%&&&&&   '@@&        .0@@@@0   '@@@* *0'&@@@%  *@@@% ",
    "0000000000           '000000%%%%%%%%&&*   %@0     .*&%@@%&^     0@@&'0&^ ^@@@@  &@@@@*",
    " ^00000000            '00000%%%%%%'.*.    *0' .*00&%@@@&0*'     ^0@@%&^   0@@&  &@@%^ ",
    "   ^000000              ^000%%%%% &@&0o.o0000&&%%@@@@%&0*^'      ^0^       ''    ''   ",
    "     ^0000               '00%%%%% ^&&%%%%&&&&000*^^'                                  ",
    "       ^00                '0%%%%'              [@KangaZero]                           ",
    "         '                  ^''                                                       ",
]

# Base gradient colours per line (dark → light → dark, mirrored)
BASE_COLORS = [
    "#52208f", "#5e2a9b", "#6a35a8", "#7641b3",
    "#824dbf", "#8f5dc9", "#9b6dd4", "#a87fda",
    "#b591e0", "#d4baee", "#d4baee", "#b591e0",
    "#a87fda", "#9b6dd4", "#8f5dc9", "#824dbf",
    "#7641b3", "#6a35a8", "#5e2a9b", "#52208f",
    "#5e2a9b", "#6a35a8", "#7641b3", "#824dbf",
]

N = len(LOGO_LINES)

# A smooth wave of highlight colours that sweeps top→bottom
# At position i in the wave, the colour peaks at white/lavender then falls back
SWEEP_PEAK   = "#ffffff"
SWEEP_BRIGHT = "#e8d5ff"
SWEEP_MID    = "#c4a0f0"


class KangaLogo(Scene):
    def construct(self):
        self.camera.background_color = "#08000f"

        # Build the text lines
        lines = VGroup()
        for text, color in zip(LOGO_LINES, BASE_COLORS):
            t = Text(text, font="Courier New", font_size=9, color=color)
            lines.add(t)

        lines.arrange(DOWN, buff=0.04, aligned_edge=LEFT)
        lines.move_to(ORIGIN)

        # ── Initial reveal: lines drop in from above with stagger ──────────
        for line in lines:
            line.set_opacity(0)

        self.play(
            LaggedStart(
                *[line.animate.set_opacity(1) for line in lines],
                lag_ratio=0.06,
                run_time=2.5,
            )
        )
        self.wait(0.4)

        # ── Infinite swoosh loop ────────────────────────────────────────────
        # Each swoosh: a band of bright colour sweeps top→bottom across lines,
        # then fades back to base. We simulate this with sequential updaters
        # by building the animation as a long sequence and using an UpdateFromFunc.

        def make_swoosh(direction=1):
            """
            Returns an animation that sweeps a highlight band across lines.
            direction=1 → top to bottom, direction=-1 → bottom to top
            """
            order = list(range(N)) if direction == 1 else list(range(N - 1, -1, -1))

            # Each line gets a quick colour flash: base → bright → base
            anims = []
            for idx in order:
                line = lines[idx]
                base = BASE_COLORS[idx]
                anims.append(
                    Succession(
                        line.animate(run_time=0.04).set_color(SWEEP_BRIGHT),
                        line.animate(run_time=0.04).set_color(SWEEP_MID),
                        line.animate(run_time=0.06).set_color(base),
                    )
                )
            return LaggedStart(*anims, lag_ratio=1.0)

        def make_pulse():
            """Gentle scale pulse on the whole group."""
            return Succession(
                lines.animate(run_time=0.35, rate_func=rush_into).scale(1.04),
                lines.animate(run_time=0.35, rate_func=rush_from).scale(1 / 1.04),
            )

        # Loop: swoosh down → wait → swoosh up → pulse → repeat
        LOOPS = 12  # increase for longer render; each loop ≈ 4s
        for i in range(LOOPS):
            self.play(make_swoosh(direction=1), run_time=2.0)
            self.wait(0.3)
            self.play(make_swoosh(direction=-1), run_time=2.0)
            self.play(make_pulse())
            self.wait(0.5)
