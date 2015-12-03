
% ---------------------------- Copyright Notice ---------------------------
% This file is part of BioPatRec � which is open and free software under
% the GNU Lesser General Public License (LGPL). See the file "LICENSE" for
% the full license governing this code and copyrights.
%
% BioPatRec was initially developed by Max J. Ortiz C. at Integrum AB and
% Chalmers University of Technology. All authors� contributions must be kept
% acknowledged below in the section "Updates % Contributors".
%
% Would you like to contribute to science and sum efforts to improve
% amputees� quality of life? Join this project! or, send your comments to:
% maxo@chalmers.se.
%
% The entire copyright notice must be kept in this or any source file
% linked to BioPatRec. This will ensure communication with all authors and
% acknowledge contributions here and in the project web page (optional).
% -------------------------- Function Description -------------------------
% logarithm Normalization
%
%
% ------------------------- Updates & Contributors ------------------------
% [Contributors are welcome to add their email]
% 2012-06-01 / Ali Fouad  / Creation
% 2014-12-04 / Ali Fouad  / Fixed warning message due to empty set

function [trSet, vSet, mMin]= NormalizeSets_normLog(trSet, vSet)
mMin =min(trSet);

trSet = log(abs(trSet - repmat(mMin,size(trSet,1),1)) +1);

vSet  = log(abs(vSet  - repmat(mMin,size(vSet ,1),1)) +1);

% the following code produce a warning after Matlab 13a
%trSet = log(abs(trSet - repmat(mMin,size(trSet,1),[])) +1);   
%vSet  = log(abs(vSet  - repmat(mMin,size(vSet ,1),[])) +1);
