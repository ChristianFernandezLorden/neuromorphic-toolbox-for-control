mfilePath = mfilename('fullpath');
if contains(mfilePath,'LiveEditorEvaluationHelper')
    mfilePath = matlab.desktop.editor.getActiveFilename;
end
[path, ~, ~] = fileparts(mfilePath);
open_system([path '\neuromorphic_blocks.slx']);

set_param(gcs,'Lock','off');
set_param(gcs,'EnableLBRepository','on');

save_system
close_system