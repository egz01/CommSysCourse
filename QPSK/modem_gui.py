import tkinter as tk
from tkinter import ttk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import (FigureCanvasTkAgg, NavigationToolbar2Tk)
from collections import namedtuple
import numpy as np

Size = namedtuple("Size", ["width", "height", "offset_x", "offset_y"])

class ModemGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("QPSK Modem")
        self.update_current_display_size()
        self.create_widgets()
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

    def on_close(self) -> None:
        self.root.quit()
        self.root.destroy()

    def update_current_display_size(self) -> None:
        self.host_screen_size = Size(self.root.winfo_screenwidth(),
                                     self.root.winfo_screenheight(), 0, 0)
        
        alpha_x = 0.8
        alpha_y = 0.8
        self.gui_display_size = Size(round(self.host_screen_size.width*alpha_x), 
                                     round(self.host_screen_size.height*alpha_y),
                                     round(self.host_screen_size.width*0.45*(1-alpha_x)),
                                     round(self.host_screen_size.height*0.1*(1-alpha_y)))
        geometry_string = "{w}x{h}+{offset_x}+{offset_y}".format(
            w=self.gui_display_size.width,
            h=self.gui_display_size.height,
            offset_x=self.gui_display_size.offset_x,
            offset_y=self.gui_display_size.offset_y
        )
        print(geometry_string)
        self.root.geometry(geometry_string)
        self.root.resizable(True, True)

    def create_widgets(self) -> None:
        self.create_tx_frame()
        self.create_rx_frame()
        self.create_channel_frame()
    
    def create_tx_frame(self) -> None:
        self.tx_frame = ttk.LabelFrame(self.root, text="Transmitter")
        w = round(self.gui_display_size.width*0.48)
        h = round(self.gui_display_size.height*0.58)
        self.tx_frame.config(width=w, height=h, relief=tk.SUNKEN, borderwidth=2)
        self.tx_frame.grid(row=0, column=0, padx=10, pady=2, sticky="nsew")
        self.tx_frame.columnconfigure(0, weight=1)
        self.tx_frame.rowconfigure(0, weight=1)

    def create_rx_frame(self) -> None:
        self.rx_frame = ttk.LabelFrame(self.root, text="Receiver")
        w = round(self.gui_display_size.width*0.48)
        h = round(self.gui_display_size.height*0.58)
        self.rx_frame.config(width=w, height=h, relief=tk.SUNKEN, borderwidth=2)
        self.rx_frame.grid(row=0, column=1, padx=10, pady=2, sticky="nsew")
        self.rx_frame.columnconfigure(0, weight=1)
        self.rx_frame.rowconfigure(0, weight=1)

    def create_channel_frame(self) -> None:
        self.channel_frame = ttk.LabelFrame(self.root, text="Channel")
        w = round(self.gui_display_size.width*0.98)
        h = round(self.gui_display_size.height*0.38)
        self.channel_frame.config(width=w, height=h, relief=tk.SUNKEN, borderwidth=2)
        self.channel_frame.grid(row=1, column=0, columnspan=2, padx=10, pady=2, sticky="nsew")

        # Channel Parameters
        self.channel_parameters_frame = ttk.Frame(self.channel_frame)
        self.channel_parameters_frame.grid(row=0, column=0, padx=10, pady=2, sticky="nsew", rowspan=4)

        self.noise_gain_label = ttk.Label(self.channel_parameters_frame, text="Noise Gain")
        self.noise_gain_label.grid(row=0, column=0, sticky="e")
        self.noise_gain_tb = ttk.Entry(self.channel_parameters_frame, width=10)
        self.noise_gain_tb.grid(row=0, column=1, sticky="w")
        self.noise_gain_tb.insert(0, "0.01")

        self.noise_std_label = ttk.Label(self.channel_parameters_frame, text="Noise STD")
        self.noise_std_label.grid(row=1, column=0, sticky="e")
        self.noise_std_tb = ttk.Entry(self.channel_parameters_frame, width=10)
        self.noise_std_tb.grid(row=1, column=1, sticky="w")
        self.noise_std_tb.insert(0, "0.3")

        self.attenuation_label = ttk.Label(self.channel_parameters_frame, text="Attenuation")
        self.attenuation_label.grid(row=2, column=0, sticky="e")
        self.attenuation_tb = ttk.Entry(self.channel_parameters_frame, width=10)
        self.attenuation_tb.grid(row=2, column=1, sticky="w")
        self.attenuation_tb.insert(0, "0.5")

        self.phase_offset_label = ttk.Label(self.channel_parameters_frame, text="Phase Offset")
        self.phase_offset_label.grid(row=3, column=0, sticky="e")
        self.phase_offset_tb = ttk.Entry(self.channel_parameters_frame, width=10)
        self.phase_offset_tb.grid(row=3, column=1, sticky="w")
        self.phase_offset_tb.insert(0, "0.0")

        # Channel Response
        if True:
            self.channel_response_frame = ttk.Frame(self.channel_frame)
            self.channel_response_frame.grid(row=0, column=1, padx=10, pady=2, sticky="nsew", rowspan=4)
            fig, axs = plt.subplots(1, 2, tight_layout=True)
            axs[0].plot([1,2,3,4], [1,4,9,16])
            axs[0].set_title('Axis [0]')

            axs[1].plot([1,2,3,4], [1,4,9,16])
            axs[1].set_title('Axis [1]')
            
            # get size from window
            dpi = self.root.winfo_fpixels('1i')
            fig.set_size_inches(w=round(self.gui_display_size.width*0.6)/dpi, h=round(self.gui_display_size.height*0.38)/dpi)

            self.channel_response_canvas = FigureCanvasTkAgg(figure=fig, master=self.channel_response_frame)
            self.channel_response_canvas.draw()
            self.channel_response_canvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=True)
            toolbar = NavigationToolbar2Tk(self.channel_response_canvas, self.channel_response_frame)
            toolbar.update()
            self.channel_response_canvas.get_tk_widget().pack(side=tk.TOP, fill=tk.BOTH, expand=True)
        
    def start(self) -> None:
        self.root.mainloop()

if __name__ == "__main__":
    modem_gui = ModemGUI()
    modem_gui.start()