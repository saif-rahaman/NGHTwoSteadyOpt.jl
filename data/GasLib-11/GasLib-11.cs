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
                    xsi:schemaLocation="http://gaslib.zib.de/CompressorStations
					http://gaslib.zib.de/schema/CompressorStations.xsd"
                    xmlns:gas="http://gaslib.zib.de/Gas"
                    xmlns:framework="http://gaslib.zib.de/CompressorStations">

  <compressorStation id="CS01_entry03_N01">
    <compressors>
      <turboCompressor drive="P_CS2_M4" id="T_CS2_M4">
        <speedMin value="3500" unit="per_min"/>
        <speedMax value="6500" unit="per_min"/>
        <n_isoline_coeff_1 value="62.0918"/>
        <n_isoline_coeff_2 value="-0.0292953"/>
        <n_isoline_coeff_3 value="4.29877e-06"/>
        <n_isoline_coeff_4 value="-58.9579"/>
        <n_isoline_coeff_5 value="0.0265692"/>
        <n_isoline_coeff_6 value="-2.57876e-06"/>
        <n_isoline_coeff_7 value="4.32767"/>
        <n_isoline_coeff_8 value="-0.00240606"/>
        <n_isoline_coeff_9 value="2.45649e-07"/>
        <eta_ad_isoline_coeff_1 value="1.16239"/>
        <eta_ad_isoline_coeff_2 value="-0.000178625"/>
        <eta_ad_isoline_coeff_3 value="6.8119e-09"/>
        <eta_ad_isoline_coeff_4 value="-0.063803"/>
        <eta_ad_isoline_coeff_5 value="8.29481e-05"/>
        <eta_ad_isoline_coeff_6 value="-6.36087e-09"/>
        <eta_ad_isoline_coeff_7 value="-0.0327073"/>
        <eta_ad_isoline_coeff_8 value="1.43794e-06"/>
        <eta_ad_isoline_coeff_9 value="1.02304e-10"/>
        <surgeline_coeff_1 value="-49.8997"/>
        <surgeline_coeff_2 value="27.7343"/>
        <surgeline_coeff_3 value="-0.0449561"/>
        <chokeline_coeff_1 value="-11.7751"/>
        <chokeline_coeff_2 value="7.27912"/>
        <chokeline_coeff_3 value="0.0567136"/>
      </turboCompressor>
    </compressors>
    <drives>
      <gasTurbine id="P_CS2_M4">
        <energy_rate_fun_coeff_1 value="5000"/>
        <energy_rate_fun_coeff_2 value="2.5"/>
        <energy_rate_fun_coeff_3 value="0"/>
        <power_fun_coeff_1 value="-1507.55"/>
        <power_fun_coeff_2 value="3.23595"/>
        <power_fun_coeff_3 value="-0.000215272"/>
        <power_fun_coeff_4 value="9.38"/>
        <power_fun_coeff_5 value="-0.02044"/>
        <power_fun_coeff_6 value="1.35429e-06"/>
        <power_fun_coeff_7 value="0.0448214"/>
        <power_fun_coeff_8 value="-8.49405e-05"/>
        <power_fun_coeff_9 value="5.83333e-09"/>
      </gasTurbine>
    </drives>
    <configurations>
      <configuration confId="1" nrOfSerialStages="1">
        <stage stageNr="1" nrOfParallelUnits="1">
          <compressor id="T_CS2_M4" nominalSpeed="5200"/>
        </stage>
      </configuration>
    </configurations>
  </compressorStation>


  <compressorStation id="CS02_N04_N05">
    <compressors>
      <turboCompressor drive="P_CS2_M4_2" id="T_CS2_M4_2">
        <speedMin value="3500" unit="per_min"/>
        <speedMax value="6500" unit="per_min"/>
        <n_isoline_coeff_1 value="62.0918"/>
        <n_isoline_coeff_2 value="-0.0292953"/>
        <n_isoline_coeff_3 value="4.29877e-06"/>
        <n_isoline_coeff_4 value="-58.9579"/>
        <n_isoline_coeff_5 value="0.0265692"/>
        <n_isoline_coeff_6 value="-2.57876e-06"/>
        <n_isoline_coeff_7 value="4.32767"/>
        <n_isoline_coeff_8 value="-0.00240606"/>
        <n_isoline_coeff_9 value="2.45649e-07"/>
        <eta_ad_isoline_coeff_1 value="1.16239"/>
        <eta_ad_isoline_coeff_2 value="-0.000178625"/>
        <eta_ad_isoline_coeff_3 value="6.8119e-09"/>
        <eta_ad_isoline_coeff_4 value="-0.063803"/>
        <eta_ad_isoline_coeff_5 value="8.29481e-05"/>
        <eta_ad_isoline_coeff_6 value="-6.36087e-09"/>
        <eta_ad_isoline_coeff_7 value="-0.0327073"/>
        <eta_ad_isoline_coeff_8 value="1.43794e-06"/>
        <eta_ad_isoline_coeff_9 value="1.02304e-10"/>
        <surgeline_coeff_1 value="-49.8997"/>
        <surgeline_coeff_2 value="27.7343"/>
        <surgeline_coeff_3 value="-0.0449561"/>
        <chokeline_coeff_1 value="-11.7751"/>
        <chokeline_coeff_2 value="7.27912"/>
        <chokeline_coeff_3 value="0.0567136"/>
      </turboCompressor>
    </compressors>
    <drives>
      <gasTurbine id="P_CS2_M4_2">
        <energy_rate_fun_coeff_1 value="5000"/>
        <energy_rate_fun_coeff_2 value="2.5"/>
        <energy_rate_fun_coeff_3 value="0"/>
        <power_fun_coeff_1 value="-1507.55"/>
        <power_fun_coeff_2 value="3.23595"/>
        <power_fun_coeff_3 value="-0.000215272"/>
        <power_fun_coeff_4 value="9.38"/>
        <power_fun_coeff_5 value="-0.02044"/>
        <power_fun_coeff_6 value="1.35429e-06"/>
        <power_fun_coeff_7 value="0.0448214"/>
        <power_fun_coeff_8 value="-8.49405e-05"/>
        <power_fun_coeff_9 value="5.83333e-09"/>
      </gasTurbine>
    </drives>
    <configurations>
      <configuration confId="1" nrOfSerialStages="1">
        <stage stageNr="1" nrOfParallelUnits="1">
          <compressor id="T_CS2_M4_2" nominalSpeed="5200"/>
        </stage>
      </configuration>
    </configurations>
  </compressorStation>

</compressorStations>
