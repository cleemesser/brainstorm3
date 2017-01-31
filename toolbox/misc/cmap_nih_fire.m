function CMap = cmap_nih_fire(varargin)

% @=============================================================================
% This function is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2016 University of Southern California & McGill University
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPLv3
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@

CMap =[
         0         0    0.1216
         0         0    0.1373
         0         0    0.1490
         0         0    0.1647
         0         0    0.1804
         0         0    0.1922
         0         0    0.2078
         0         0    0.2235
         0         0    0.2353
         0         0    0.2510
         0         0    0.2706
         0         0    0.2863
         0         0    0.3020
    0.0039         0    0.3176
    0.0039         0    0.3373
    0.0039         0    0.3529
    0.0039         0    0.3686
    0.0118         0    0.3843
    0.0196         0    0.4000
    0.0314         0    0.4157
    0.0431         0    0.4353
    0.0549         0    0.4510
    0.0667         0    0.4667
    0.0784         0    0.4824
    0.0902         0    0.4980
    0.1020         0    0.5137
    0.1137         0    0.5333
    0.1255         0    0.5490
    0.1373         0    0.5647
    0.1490         0    0.5804
    0.1569         0    0.6000
    0.1686         0    0.6157
    0.1804         0    0.6314
    0.1922         0    0.6471
    0.2039         0    0.6627
    0.2157         0    0.6745
    0.2275         0    0.6863
    0.2392         0    0.6980
    0.2510         0    0.7137
    0.2627         0    0.7255
    0.2745         0    0.7373
    0.2863         0    0.7529
    0.2980         0    0.7647
    0.3098         0    0.7765
    0.3216         0    0.7922
    0.3333         0    0.8039
    0.3451         0    0.8196
    0.3569         0    0.8314
    0.3686         0    0.8431
    0.3804         0    0.8588
    0.3922         0    0.8667
    0.4039         0    0.8667
    0.4157         0    0.8706
    0.4275         0    0.8745
    0.4353         0    0.8784
    0.4471         0    0.8824
    0.4588         0    0.8863
    0.4706         0    0.8863
    0.4824         0    0.8863
    0.4941         0    0.8784
    0.5059         0    0.8706
    0.5176         0    0.8627
    0.5294         0    0.8549
    0.5412         0    0.8471
    0.5529         0    0.8392
    0.5647         0    0.8314
    0.5725         0    0.8196
    0.5804         0    0.8078
    0.5882         0    0.7922
    0.5961         0    0.7804
    0.6039         0    0.7647
    0.6118         0    0.7529
    0.6196         0    0.7373
    0.6275         0    0.7255
    0.6353         0    0.7098
    0.6392         0    0.6980
    0.6471         0    0.6824
    0.6510         0    0.6667
    0.6549         0    0.6549
    0.6627         0    0.6392
    0.6667         0    0.6235
    0.6706         0    0.6118
    0.6784         0    0.5961
    0.6824         0    0.5843
    0.6863         0    0.5686
    0.6941         0    0.5529
    0.6980         0    0.5412
    0.7020         0    0.5255
    0.7098         0    0.5137
    0.7137         0    0.4980
    0.7176         0    0.4863
    0.7255         0    0.4706
    0.7294         0    0.4588
    0.7333         0    0.4431
    0.7412         0    0.4314
    0.7451         0    0.4157
    0.7490         0    0.4039
    0.7569         0    0.3882
    0.7608         0    0.3765
    0.7647         0    0.3608
    0.7725    0.0078    0.3490
    0.7765    0.0157    0.3333
    0.7843    0.0235    0.3216
    0.7882    0.0275    0.3059
    0.7961    0.0353    0.2941
    0.8000    0.0431    0.2784
    0.8078    0.0471    0.2627
    0.8118    0.0549    0.2510
    0.8157    0.0667    0.2353
    0.8196    0.0745    0.2235
    0.8275    0.0863    0.2078
    0.8314    0.0941    0.1961
    0.8353    0.1059    0.1804
    0.8392    0.1137    0.1686
    0.8471    0.1255    0.1529
    0.8510    0.1333    0.1412
    0.8549    0.1451    0.1255
    0.8627    0.1569    0.1137
    0.8667    0.1647    0.0980
    0.8745    0.1765    0.0824
    0.8784    0.1882    0.0706
    0.8824    0.1961    0.0549
    0.8902    0.2078    0.0392
    0.8941    0.2196    0.0275
    0.9020    0.2275    0.0196
    0.9059    0.2392    0.0157
    0.9098    0.2510    0.0118
    0.9176    0.2588    0.0118
    0.9216    0.2706    0.0078
    0.9255    0.2824    0.0078
    0.9333    0.2941    0.0039
    0.9373    0.3020         0
    0.9412    0.3137         0
    0.9490    0.3255         0
    0.9529    0.3333         0
    0.9608    0.3451         0
    0.9647    0.3569         0
    0.9725    0.3647         0
    0.9765    0.3765         0
    0.9843    0.3882         0
    0.9882    0.3961         0
    0.9882    0.4039         0
    0.9922    0.4118         0
    0.9922    0.4196         0
    0.9922    0.4275         0
    0.9961    0.4353         0
    0.9961    0.4431         0
    1.0000    0.4510         0
    1.0000    0.4588         0
    1.0000    0.4667         0
    1.0000    0.4745         0
    1.0000    0.4824         0
    1.0000    0.4902         0
    1.0000    0.4941         0
    1.0000    0.5020         0
    1.0000    0.5098         0
    1.0000    0.5176         0
    1.0000    0.5255         0
    1.0000    0.5333         0
    1.0000    0.5373         0
    1.0000    0.5451         0
    1.0000    0.5529         0
    1.0000    0.5608         0
    1.0000    0.5647         0
    1.0000    0.5725         0
    1.0000    0.5804         0
    1.0000    0.5843         0
    1.0000    0.5922         0
    1.0000    0.6000         0
    1.0000    0.6039         0
    1.0000    0.6118         0
    1.0000    0.6196         0
    1.0000    0.6275         0
    1.0000    0.6314         0
    1.0000    0.6392         0
    1.0000    0.6471         0
    1.0000    0.6510         0
    1.0000    0.6588         0
    1.0000    0.6667         0
    1.0000    0.6706         0
    1.0000    0.6784         0
    1.0000    0.6863         0
    1.0000    0.6941         0
    1.0000    0.7020         0
    1.0000    0.7059         0
    1.0000    0.7137         0
    1.0000    0.7216         0
    1.0000    0.7294         0
    1.0000    0.7373         0
    1.0000    0.7412         0
    1.0000    0.7490         0
    1.0000    0.7569         0
    1.0000    0.7647         0
    1.0000    0.7725         0
    1.0000    0.7804         0
    1.0000    0.7843         0
    1.0000    0.7922         0
    1.0000    0.8000         0
    1.0000    0.8078         0
    1.0000    0.8157         0
    1.0000    0.8196         0
    1.0000    0.8275         0
    1.0000    0.8353         0
    1.0000    0.8392         0
    1.0000    0.8471         0
    1.0000    0.8549         0
    1.0000    0.8588         0
    1.0000    0.8667         0
    1.0000    0.8745         0
    1.0000    0.8824         0
    1.0000    0.8902         0
    1.0000    0.8980         0
    1.0000    0.9020         0
    1.0000    0.9098         0
    1.0000    0.9176         0
    1.0000    0.9255    0.0157
    1.0000    0.9294    0.0353
    1.0000    0.9373    0.0510
    1.0000    0.9451    0.0667
    1.0000    0.9529    0.0824
    1.0000    0.9569    0.1020
    1.0000    0.9647    0.1176
    1.0000    0.9725    0.1333
    1.0000    0.9765    0.1608
    1.0000    0.9804    0.1922
    1.0000    0.9804    0.2196
    1.0000    0.9843    0.2510
    1.0000    0.9882    0.2824
    1.0000    0.9922    0.3098
    1.0000    0.9961    0.3412
    1.0000    1.0000    0.3725
    1.0000    1.0000    0.4000
    1.0000    1.0000    0.4314
    1.0000    1.0000    0.4588
    1.0000    1.0000    0.4902
    1.0000    1.0000    0.5176
    1.0000    1.0000    0.5490
    1.0000    1.0000    0.5765
    1.0000    1.0000    0.6078
    1.0000    1.0000    0.6392
    1.0000    1.0000    0.6667
    1.0000    1.0000    0.6980
    1.0000    1.0000    0.7255
    1.0000    1.0000    0.7569
    1.0000    1.0000    0.7882
    1.0000    1.0000    0.8157
    1.0000    1.0000    0.8471
    1.0000    1.0000    0.8745
    1.0000    1.0000    0.8902
    1.0000    1.0000    0.9059
    1.0000    1.0000    0.9216
    1.0000    1.0000    0.9373
    1.0000    1.0000    0.9529
    1.0000    1.0000    0.9686
    1.0000    1.0000    0.9843
    1.0000    1.0000    0.9961];
     
     
     
     