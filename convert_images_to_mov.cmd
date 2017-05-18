@echo off
:: 2017_03_26 V1.0 ����ΰ
:: ����ű�ͨ����ק����֡�����ļ��н����������֡ת��mov��
:: Todo:
:: �Զ�ʶ����ק�����ļ��л��ļ�����ִ����Ӧ�Ĳ�����
:: ����ļ��������ļ������Զ����ѡ�
:: ����ļ���û������֡���ܹ����ѡ�
:: ����ĸ߱�����ż���������޷����������
:: �Զ�����mov
:: ��дcommon�ĵط�

setlocal EnableDelayedExpansion

set out_width=1920
set out_height=1080
set quality=10
set mask_ratio=2.35
set mask_opacity=1
set mask_color=black
set lut=lut3d='s\:/generic_elements/lut/AlexaV3_K1S1_LogC2Video_Rec709_EE_nuke3d.cube',
set input_fps=24
set output_fps=24
set pad_color=black

:: �ڷ���slate��LUT�Ŀ���
set slate_on=1
set lut_on=1
set mask_on=1

:: Slate����
set project=������
set company=����һ��
set font=C\\:/Windows/Fonts/simhei.ttf
set font_color=white
set font_opacity=0.8
set shot_font_size=36
set other_font_size=26
set left=50
set right=50
set top=90
set shot_top=30
set bottom=90

:: FFMPEG����·��
set ffmpeg_path="\\work\app_config\release\ffmpeg\bin\ffmpeg.exe" 
set ffprobe_path="\\work\app_config\release\ffmpeg\bin\ffprobe.exe"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ������ק���ļ��еõ�ffmpeg��Ҫ�����������ļ�·��


:: ��ȡ��ק���ű��ϵİ���·���������ļ���
set input_dir=%~f1
set input_up_folder=%~dp1
set output_folder=%input_up_folder%mov\
if not exist %output_folder% ( md %output_folder% )
::goto :end

echo input_dir:%input_dir%
echo input_up_folder:%input_up_folder%
echo output_folder:%output_folder%

:: ��ȡ·���ڰ���������ĵ�һ���ļ���
for /f "usebackq" %%a in (`dir /O:N /A:-H /B "%input_dir%"`) do (
set fullfilename=%%a
goto out1
)
:out1
echo fullfilename:%fullfilename%

set fp_file_name=%input_dir%\%fullfilename%
echo fp_file_name: %fp_file_name%

:: ��"."Ϊ�ֽ罫�ļ����ֿ����ѵ�һ���͵ڶ���������name ��frame��
:: ������Ҫʶ�����û������֡�������
for /f "usebackq tokens=1,2 delims=." %%b in ('%fullfilename%') do (@set clean_name=%%b& @set start_frame=%%c)
echo start_frame: %start_frame%

:: ��"."Ϊ�ֽ���ļ����ֿ�ȡ�����ε���չ����
:: ��������ܱ�������ļ�ֻ�������־ͻ����
for /f "usebackq tokens=3 delims=." %%e in ('%fullfilename%') do (set ext=%%e)

:: ����ffmpeg��Ҫ������֡�ļ���
set ff_filename=%clean_name%.%%d.%ext%
set ff_fullpath=%input_dir%\%clean_name%.%%d.%ext%
set ff_full_out_path=%output_folder%%clean_name%.mov
echo ff_fullpath: %ff_fullpath%
echo ff_full_out_path:%ff_full_out_path%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: ��ȡ�����زĵ�ͼƬ��͸ߡ� 
:: �м���һ����ʱ�ļ��洢�õ��Ŀ��ֵ��Ȼ���ٶ�ȡ������ֵ��batch�޷�ֱ�ӽ�һ����������ֵ������һ������
%ffprobe_path%  -v error -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 %fp_file_name% > %TEMP%\M0vyyyeah.tmp
%ffprobe_path%  -v error -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 %fp_file_name% >> %TEMP%\M0vyyyeah.tmp

<%TEMP%\M0vyyyeah.tmp (
  set /p i_width=
  set /p i_height=
)

echo i_width:%i_width%
echo i_height:%i_height%

:: �ȶ������ʽ�������ʽ�Ļ����ȴ�С���������Ŀ�߱ȴ�������Ŀ�߱ȣ�����Ҫcrop����Ļ��棬��С�ڻ��������Ҫpad����Ļ��档
:: ��Ϊbatch��֧��С�����������Էֱ����������height�ֱ���ԶԷ���width�ȴ�С����������������crop�����С�������pad��

set /a in_height_b=%i_height%*%out_width%
set /a out_height_b=%out_height%*%i_width%
echo in_height_b:%in_height_b%
echo out_height_b:%out_height_b%

:: �����Ƿ�����mask��lut��slate
:: lut
if %lut_on% NEQ 1 (set lut=)
:: mask
if %mask_on% NEQ 1 (set mask=) else (set mask=drawbox=x=-t:y=0.5*^(ih-iw/%mask_ratio%^)-t:w=iw+t*2:h=iw/%mask_ratio%+t*2:t=0.5*^(ih-iw/%mask_ratio%^):c=%mask_color%@%mask_opacity%,)
:: slate
if %slate_on% NEQ 1 (set mask=) else (set slate=drawtext=fontfile=%font%: text=%clean_name%:x=w/2-tw/2:y=%shot_top%: fontsize=%shot_font_size%: fontcolor=%font_color%@%font_opacity%,drawtext=fontfile=%font%: text=%company%:x=w/2-tw/2:y=%top%: fontsize=%other_font_size%: fontcolor=%font_color%@%font_opacity%,drawtext=fontfile=%font%: text=%project%:x=%left%:y=%top%: fontsize=%other_font_size%: fontcolor=%font_color%@%font_opacity%, drawtext=fontfile=%font%: text=^'%%{localtime}^':x=w-tw-%right%:y=%top%: fontsize=%other_font_size%: fontcolor=%font_color%@%font_opacity%,drawtext=fontfile=%font%:start_number=%start_frame%:text=^'%%{n}^':x=w-tw-%right%:y=h-%bottom%: fontsize=%shot_font_size%: fontcolor=%font_color%@%font_opacity%,)

:: ffmpeg filter�ǰ�˳����еģ������Զ�����Ӱ��ܴ���pad��scale����scale��pad���������ĳߴ��ǲ�һ���ġ�������scaleҪ����ǰ�档
if %in_height_b% EQU %out_height_b% (set ff_filter="scale=%out_width%:-2,%lut% %mask% %slate% fps=%output_fps%") && goto :out2
if %in_height_b% LSS %out_height_b% (set ff_filter="scale=%out_width%:-2,pad=x=0:y=(oh-ih)/2:w=0:h=%out_height%:color=%pad_color%,%lut% %mask% %slate% fps=%output_fps%") && goto :out2
if %in_height_b% GTR %out_height_b% (set ff_filter="scale=%out_width%:-2,crop=%out_width%:%out_height%,%lut% %mask% %slate% fps=%output_fps%") && goto :out2

:out2


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ��ʼת�벢��������ļ���

%ffmpeg_path% -framerate %input_fps% -start_number %start_frame% -i %ff_fullpath% -c:v libx264 -crf %quality%  -bf 0 -g 1 -pix_fmt yuv420p  -vf %ff_filter% %ff_full_out_path% && %SystemRoot%\explorer.exe %output_folder%


:end
pause