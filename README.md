# Tube_Analysis

Workflow Description
  Step 1 : Open the image / Choose a saving directory for the output results
  Step 2 : Denoising Step, choice between different options
          Option 1 : CLAHE (linearize the intensity) then Rolling ball background substraction
          Option 2 : CLAHE on resliced image XZY (Linearize the intensity along the depth) then Rolling ball background substraction then reslice to get back to the XYZ format
          Option 3 : Haar Wavelet then Rolling ball background substraction
  Step 3 : Work on two different channels : Actin and Nucleus
       Nuclei Analysis optional depending on the image : If 10X, it will not perform well
    The nuclei analysis follow this process : 
     ==> Binarization above a "good" threshold
     ==> Remove Outliers
     ==> Fill Holes
     ==> Watershed
     ==> Watershed 3D  (those two steps is to separate close nuclei
     ==> New binary
     ==> Erosion
     ==> Run 3D Object counter 
     ==> Output is csv file with various information
 
        Tube Analysis is optional and follow this process : 
 Using the actin channel
 Reslice is performed and rescale is done such as XZ pixels are square
 A function SplitTube is called to split the image accordingly to the number of tubes present in the image
 On each Split image, a function  CanalEllipse will perform a fitting by finding the convex hull
 It will gather the information regarding the minor and major axis and the orientation of the ellipse regarding the orthogonal coordinates
 
 Finally, some graphs will be realised and saved
 
 Step 4 : Work on combined channels to get information of the density %Volume
 Binarization of both channels is performed
 Sum of Actin Channel and Nuclei Channel is done
 %Area is calculated by measuring of the Area of material for a slice / Total Area covered by the Ellipse
 A final graph is done presenting the %Area along the tube axis and for each tube
 
 
     
