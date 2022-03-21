<?xml version="1.0" encoding="UTF-8"?>

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!--                                                                                   -->
<!--                  This file is part of the BMWi project 0328006                    -->
<!--                      Technical Capacities of Gas Networks                         -->
<!--                                                                                   -->
<!-- Copyright (C) 2013                                                                -->
<!-- FAU Erlangen-Nuremberg, HU Berlin, LU Hannover, TU Darmstadt,                     -->
<!-- University Duisburg-Essen, WIAS Berlin, Zuse Institute Berlin                     -->
<!-- Contact: Thorsten Koch (koch@zib.de)                                              -->
<!-- All rights reserved.                                                              -->
<!--                                                                                   -->
<!-- This work is licensed under the Creative Commons Attribution 3.0 Unported License.-->
<!-- To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ -->
<!-- or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View,-->
<!-- California, 94041, USA.                                                           -->
<!--                                                                                   -->
<!--                         Please note that you have to cite                         -->
<!-- Pfetsch et al. (2012) "Validation of Nominations in Gas Network Optimization:     -->
<!-- Models, Methods, and Solutions", ZIB-Report 12-41                                 -->
<!--                               if you use this data                                -->
<!--                                                                                   -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<compressorStations xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xmlns="http://gaslib.zib.de/CompressorStations"
                    xsi:schemaLocation="http://gaslib.zib.de/CompressorStations CompressorStations.xsd"
                    xmlns:gas="http://gaslib.zib.de/Gas"
                    xmlns:framework="http://gaslib.zib.de/CompressorStations">
  <compressorStation id="compressorStation_1">
    <compressors>
      <turboCompressor drive="drive_1" id="compressor_1">
        <speedMin value="5760" unit="per_min"/>
        <speedMax value="11600" unit="per_min"/>
        <n_isoline_coeff_1 value="-9.12494"/>
        <n_isoline_coeff_2 value="0.00210704"/>
        <n_isoline_coeff_3 value="6.98108e-08"/>
        <n_isoline_coeff_4 value="10.566"/>
        <n_isoline_coeff_5 value="-0.00011885"/>
        <n_isoline_coeff_6 value="1.33716e-07"/>
        <n_isoline_coeff_7 value="-10.5652"/>
        <n_isoline_coeff_8 value="0.00066214"/>
        <n_isoline_coeff_9 value="-3.50928e-08"/>
        <eta_ad_isoline_coeff_1 value="1.30314"/>
        <eta_ad_isoline_coeff_2 value="-0.000270759"/>
        <eta_ad_isoline_coeff_3 value="1.36317e-08"/>
        <eta_ad_isoline_coeff_4 value="0.368873"/>
        <eta_ad_isoline_coeff_5 value="0.000203474"/>
        <eta_ad_isoline_coeff_6 value="-1.52475e-08"/>
        <eta_ad_isoline_coeff_7 value="-0.77351"/>
        <eta_ad_isoline_coeff_8 value="6.18951e-05"/>
        <eta_ad_isoline_coeff_9 value="-6.34336e-10"/>
        <surgeline_coeff_1 value="-77.6315"/>
        <surgeline_coeff_2 value="118.291"/>
        <surgeline_coeff_3 value="-24.711"/>
        <chokeline_coeff_1 value="0.168264"/>
        <chokeline_coeff_2 value="-0.228366"/>
        <chokeline_coeff_3 value="2.47995"/>
      </turboCompressor>
    </compressors>
    <drives>
      <gasTurbine id="drive_1">
        <energy_rate_fun_coeff_1 value="4001.75"/>
        <energy_rate_fun_coeff_2 value="2.60806"/>
        <energy_rate_fun_coeff_3 value="4.45109e-07"/>
        <power_fun_coeff_1 value="40.5236"/>
        <power_fun_coeff_2 value="0.596875"/>
        <power_fun_coeff_3 value="-2.49783e-05"/>
        <power_fun_coeff_4 value="-0.32098"/>
        <power_fun_coeff_5 value="-0.00366812"/>
        <power_fun_coeff_6 value="1.5354e-07"/>
        <power_fun_coeff_7 value="0.00120491"/>
        <power_fun_coeff_8 value="4.3757e-06"/>
        <power_fun_coeff_9 value="-2.01141e-10"/>
      </gasTurbine>
    </drives>
    <configurations>
      <configuration nrOfSerialStages="1" confId="config_1">
        <stage nrOfParallelUnits="1" stageNr="1">
          <compressor nominalSpeed="7000" id="compressor_1"/>
        </stage>
      </configuration>
    </configurations>
  </compressorStation>
</compressorStations>
