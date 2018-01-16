function [pred_outcome_r, sl_size] = searchlight_predict(dat, varargin)
% Calculate  local prediction accuracy using the searchlight approach. 
%
% :Usage:
% ::
%
%     [r_corr, dat, sl_size] = searchlight_predict(dat, [additional_inputs])
% 
%
% :Inputs:
%
%   **dat:**
%        fmri object for prediction
%
% :Optional inputs: 
%
%   **'r':**
%        searchlight sphere radius (in voxel) (default: r = 3 voxels)
%
%
% :Outputs:
%
%   **searchlight_map:**
%        prediction-outcome correlation map
%
%   **dat:**
%        This contains a statistic_image object that contains 
%        prediction outcome correlation values between
%
%   **sl_size:**
%        The number of voxels within each searchlight. Based on this 
%        number, you can detect searchlights on the edge (searchlights 
%        with low sl_size should be on the edge of the brain.
%
% ..
%     Author and copyright information:
%
%     Copyright (C) 2014  Wani Woo, 2018 - adaption for prediction instead of
%     correlation by Phil Kragel 
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ..
%
% :Examples:
% ::
%


 
r = 4; % default radius (in voxel)
nfolds = 5;
alg= 'cv_lassopcr';
% parsing varargin

for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands

            case 'r' % radius
                r = varargin{i+1};
            case 'alg'
                alg = varargin{i+1};
            case 'nfolds'
                nfolds = varargin{i+1};
                
        end
    end
end



n = size(dat.dat,1);

pred_outcome_r = NaN(n,1);
p = NaN(n,1);
sl_size = zeros(n,1);
dat=remove_empty(dat);
fprintf('\n Performing prediction for voxel                 ');
for i = 1:n %(1):vox_to_run(10)
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%07d/%07d', i, n);
    searchlight_indx = searchlight_sphere_prep(dat.volInfo.xyzlist(~dat.removed_voxels,:), i, r);
    tv=dat;
    tv.dat=tv.dat(searchlight_indx,:);

    [~, stats]=predict(tv, 'algorithm_name', alg, 'nfolds',nfolds,'verbose',0);
     pred_outcome_r(i) = stats.pred_outcome_r;
    sl_size(i) = sum(searchlight_indx);
    
    
end

end

% ========== SUBFUNCTION ===========

function indx = searchlight_sphere_prep(xyz, i, r)
seed = xyz(i,:);
indx = sum([xyz(:,1)-seed(1) xyz(:,2)-seed(2) xyz(:,3)-seed(3)].^2, 2) <= r.^2;
end


