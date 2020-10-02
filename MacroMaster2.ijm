// Macro Tube Analysis developed by Bertrand Cinquin Last Update 08 04 2020
// This macro intends to describe some features regarding the number of nucleus (ie. cells) and the ellipsity of the tubes
// formed to mimick kidneys tubes
// 
// Running the macro will leads to different pop-up windows and menu
// After selecting the tiff file (in which the name should not have any dots), and selecting the working folder where all the images, tables results and graphs 
// will be saved
// A menu will ask you to select different options : 
// number of tubes to analyse as there are files with one tube and some with 5
// which kind of denoising need to be performed : different options are available.
// It's a rather slow process but once it's done, the result is saved and a second run will check if the file exist or not and it will work from there
// Do you want a nuclei analysis or only the tube analysis : it will use the actin channel to perform.
//


//In the saving folders, you will find for each tube :
//"name"_enveloppe : border of the tube
//"name"_resliced : orthoslice of the tube
//"name"_resliced_envelope :  border of the orthoslices
//"name"_nucleus_objectmap and the results :  nuclei masks and parameters for each nuclei
//"name"_ROITUBE.zip : region of interests for all ellipse fitting the tube
//"name"_%Area /Tube Angle/Tube Area/Tube Perimeter : graphs representing these different measures
//"name"_Results.cvs : a table holding the different measures


run("Set Measurements...", "area mean perimeter fit area_fraction redirect=None decimal=3");
colorArray=newArray("green", "blue", "cyan", "darkGray", "orange", "black", "lightGray", "magenta", "gray", "pink", "red", "white","yellow");
Table.create("Final_Results");

//Open Image to Analyse
PathImage= File.openDialog("Choose your image");
DirSource=File.getParent(PathImage);
Dir1 = getDirectory("Choose a Directory to save images");
open(PathImage);
ImageName = File.getName(PathImage); print(ImageName);
ImageNameNoExt = File.nameWithoutExtension;print(ImageNameNoExt);



DirSource=File.getParent(PathImage);
ImageName = File.getName(PathImage); 
ImageNameNoExt = File.nameWithoutExtension;

//print(DirSource,ImageName, ImageNameNoExt,PathImage,type,NucleiAnalysis,TubeAnalysis,TubeNumber,Nucleus_Channel,Actin_Channel);


Dialog.create("Analysis Choices");
Dialog.addChoice("Denoising Type :", newArray("Clahe","Clahe_Reslice","Haar Wavelet"));
Dialog.addCheckbox("Nuclei Analysis", false);
Dialog.addCheckbox("Tube Analysis", true);
Dialog.addNumber("Number of Tubes", 5);
Dialog.addNumber("Nucleus Channel Number", 3);
Dialog.addNumber("Actin Channel Number", 2);
Dialog.show();
type = Dialog.getChoice();
NucleiAnalysis= Dialog.getCheckbox();
TubeAnalysis = Dialog.getCheckbox()
TubeNumber = Dialog.getNumber();
Nucleus_Channel = Dialog.getNumber();
Actin_Channel = Dialog.getNumber();
print(type,NucleiAnalysis,TubeAnalysis,TubeNumber);

//ImageNameNoExtension = File.nameWithoutExtension(ImageName);
//Select Actin/Nucleus Channel
getDimensions(width, height, channels, slices, frames)
run("Make Substack...", "channels="+Actin_Channel+","+Nucleus_Channel+" slices=1-"+slices);
rename("Actin_Nucleus");
close(ImageName);


//Denoising Method 0 CLAHE and Subs
if (type == "Clahe"){
	isAlreadyThere = File.exists(Dir1+"\\"+ImageNameNoExt+"_Clahe.tif");
	if (isAlreadyThere != 1) {
		for (i = 1; i <= nSlices; i++) {
			setSlice (i);
			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None*");
		}
		run("Subtract Background...", "rolling=30 stack");
		save(Dir1+"\\"+ImageNameNoExt+"_Clahe.tif");
		rename("Actin_Nucleus_Denoised");
	}
	if(isAlreadyThere == 1){
		open(Dir1+"\\"+ImageNameNoExt+"_Clahe.tif");
		rename("Actin_Nucleus_Denoised");
	}
}
//Method 1 Reslice
if (type == "Clahe_Reslice"){
	isAlreadyThere = File.exists(Dir1+"\\"+ImageNameNoExt+"_ReslicedClahe.tif");
	if (isAlreadyThere != 1) {
		for (i = 1; i <= nSlices; i++) {
			setSlice (i);
			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None*");
		}
		run("Reslice [/]...", "output=5.000 start=Top avoid");
		for (i = 2; i <= nSlices; i++) {
			setSlice(i);
			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None*");
		}
		run("Reslice [/]...", "output=5.000 start=Top avoid");
		run("Subtract Background...", "rolling=30 stack");
		save(Dir1+"\\"+ImageNameNoExt+"_ReslicedClahe.tif");
		rename("Actin_Nucleus_Denoised");
		close("Reslice of Actin_Nucleus");
	}
	if(isAlreadyThere == 1){
		open(Dir1+"\\"+ImageNameNoExt+"_ReslicedClahe.tif");
		rename("Actin_Nucleus_Denoised");
	}
	
}
//Method 2 Haar
if (type == "Haar Wavelet"){
	isAlreadyThere = File.exists(Dir1+"\\"+ImageNameNoExt+"_HaarWavelet.tif");
	if (isAlreadyThere != 1) {
		for (i = 1; i <= nSlices; i++) {
			setSlice(i);
			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None*");
			run("Haar wavelet filter", "k1=2 k2=2 k3=2 std=1.6");
			selectWindow("Actin_Nucleus");
		}
		run("Images to Stack", "name=Stack_Denoised title=Denoised use");
		run("Subtract Background...", "rolling=30 stack");
		selectWindow("Stack_Denoised");
		run("Deinterleave", "how=2");
		run("Merge Channels...", "c2=[Stack_Denoised #1] c3=[Stack_Denoised #2] create");
		save(Dir1+"\\"+ImageNameNoExt+"_HaarWavelet.tif");
		rename("Actin_Nucleus_Denoised");
	}
	if(isAlreadyThere == 1){
		open(Dir1+"\\"+ImageNameNoExt+"_HaarWavelet.tif");
		rename("Actin_Nucleus_Denoised");
	}
}

//Split Actin and Nucleus
selectWindow("Actin_Nucleus_Denoised");
run("Duplicate...", "duplicate channels=1");
rename("Actin");
selectWindow("Actin_Nucleus_Denoised");
run("Duplicate...", "duplicate channels=2");
rename("Nucleus");
close("Actin_Nucleus_Denoised");
close("Actin_Nucleus");

if(NucleiAnalysis ==1){
//Analyse Nucleus
selectWindow("Nucleus");
//Open Image
// Clean Image
// Mask
// Watershade 2D

// WaterShade 3D
// Erode
// 3D Counting
setSlice(nSlices/2);
run("Make Binary", "method=MinError background=Default black");
run("Remove Outliers...", "radius=2 threshold=50 which=Bright stack");
run("Fill Holes", "stack");
run("Watershed", "stack");
run("Distance Transform Watershed 3D", "distances=[Borgefors (3,4,5)] output=[16 bits] normalize dynamic=2 connectivity=26");
setSlice(nSlices/2);
rename("WaterShaded");
selectWindow("WaterShaded");
run("Make Binary", "method=MinError background=Default calculate black");

run("Erode", "stack");
run("3D OC Options", "volume surface nb_of_obj._voxels dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");

run("3D Objects Counter", "threshold=128 slice=107 min.=200 max.=5335440 objects statistics summary");
save(Dir1+"\\"+ImageNameNoExt+"_NucleusObjectMap.tif");
saveAs("Results", Dir1+"\\"+ImageNameNoExt+"_NucleusObjectMapResults.csv");
//Ultimate Points based representation
/*Name = getInfo("image.filename");
run("Set Measurements...", "area mean min centroid fit redirect=None decimal=3");
run("Erode","stack");
run("Fill Holes","stack");
run("Smooth", "stack");run("Smooth", "stack");
run("Make Binary", "method=MinError background=Default calculate black");
run("Watershed", "stack");
setAutoThreshold("Percentile dark");
run("Ultimate Points","stack");
run("Analyze Particles...", "size=1-1 pixel display add stack");
Name = getInfo("window.title");print(Name);
selectWindow(Name); NumSlice = nSlices;
getVoxelSize(width, height, depth, unit);
PosX = newArray(roiManager("Count"));
PosY = newArray(roiManager("Count"));
MeanUP = newArray(roiManager("Count"));
 		
 	 for (j = 0; j < roiManager("Count"); j++) {
 	 		PosX[j] = getResult("X",j)/width;
 	 		PosY[j] = getResult("Y",j)/height;
 	 		MeanUP[j] = getResult("Mean",j);
 			roiManager("select",j);
 			if(MeanUP[j] >3){
  				fillOval(PosX[j], PosY[j], MeanUP[j]*1, MeanUP[j]*1);
  				//	waitForUser("Pause");
 			}
 	 }		
 		//CLean ROI Manager
 		SelectArray = newArray(roiManager("Count"));
 		for (k = 0; k < roiManager("Count"); k++) {
 			SelectArray[k]=k;
  		}
 		roiManager("select",SelectArray);roiManager("delete");
 		selectWindow("Results");run("Close");

 	//Object counting 3D
close("Log");
run("3D OC Options", "volume surface nb_of_obj._voxels dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
run("3D Objects Counter", "threshold=3 slice=20 min.=200 max.=1935360 exclude_objects_on_edges objects summary");
*/
selectWindow("Log");
LastLogEntry = getInfo();print(LastLogEntry);
NumofNuc=(substring(LastLogEntry, 13, 16));
print(parseInt(NumofNuc));
	if (NumofNuc == NaN){
		NumofNuc= (substring(LastLogEntry, 14, 17));print(parseInt(NumofNuc));
	}
	if (NumofNuc == NaN){
		NumofNuc= (substring(LastLogEntry, 14, 16));print(parseInt(NumofNuc));
	}
waitForUser("Number of nucleus is "+parseInt(NumofNuc));
save(Dir1+"\\"+ImageNameNoExt+"_NucleusObjectMap.tif");

}





if(TubeAnalysis ==1){
//Analyse Actin
selectWindow("Actin");
stacksize = nSlices;

getVoxelSize(width, height, depth, unit);
pxl_width = width; pxl_height = height; pxl_depth = depth;
getDimensions(width, height, channels, slices, frames);
Numpxls_width = width; Numpxls_height = height; 
print(pxl_width,pxl_height,pxl_depth,Numpxls_width,Numpxls_height);
selectWindow("Actin");
run("Reslice [/]...", "output="+pxl_depth+" start=Top avoid");
NewHeight = slices*pxl_depth*pxl_height;
print(NewHeight);
waitForUser("Pause");
run("Size...", "width="+Numpxls_width+" height="+ NewHeight+" depth=446 interpolation=None");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
run("Set Scale...", "distance="+NewHeight +" known="+depth*slices+" unit=microns");
waitForUser("Pause");
//Create Channels
SplitTube(TubeNumber,"Reslice of Actin",ImageNameNoExt);
WindowNames = newArray(TubeNumber);
	NumFrames = nSlices;
	Ellipse = newArray(NumFrames*TubeNumber);
	Length = newArray(NumFrames*TubeNumber);
	Angle= newArray(NumFrames*TubeNumber);
	Perimeter = newArray(NumFrames*TubeNumber);


for (i = 0; i < TubeNumber; i++) {
	WindowNames[i]=ImageNameNoExt+"_Resliced_"+i+1+"";
}

for (i = 0; i<WindowNames.length; i++) {
	selectWindow(WindowNames[i]);
	run("ROI Manager...");
	setBatchMode(true);
	for (j = 1; j <= nSlices; j++) {
	setSlice(j);
	setAutoThreshold("Default dark");
	run("Measure");
	selectWindow("Results");
	Int = getResult("Mean", j-1);
	selectWindow(WindowNames[i]);
		if (Int != 0) {
			CanalEllipse();	
		}
	}
	save(Dir1+"\\"+ImageNameNoExt+"_Resliced_"+i+1);
	roiManager("save", Dir1+"\\"+ImageNameNoExt+"RoiTube"+i+1+".zip");
	setBatchMode(false);
	//Draw Tube Enveloppe
	newImage("Tube Enveloppe"+i+1, "8-bit black", width/TubeNumber, stacksize, nSlices);
	for (k = 0; k < roiManager("count"); k++) {
		roiManager("Select",k);
		setSlice(k+1);
		run("Draw",  "slice");
	}
	run("Select All");
	save(Dir1+"\\"+ImageNameNoExt+"_Resliced_Envelope_"+i+1+".tif");
	run("Reslice [/]...", "output="+depth+" start=Top avoid");
	save(Dir1+"\\"+ImageNameNoExt+"_Envelope_"+i+1);
	PathSave = Dir1+"\\"+ImageNameNoExt;
	selectWindow("Results");run("Close");
	
	//Extract Measures
	//Major Minor Axis
	Table.create("Results");
	newImage("Temp", "8-bit white", 184, 350, 1);
	Major_Array = newArray(roiManager("count"));
	Minor_Array = newArray(roiManager("count"));
	RatioAxis_Array = newArray(roiManager("count"));
	
	for (k = 0; k < roiManager("count"); k++) {
		roiManager("select",k);
		run("Measure");
		Major_Array[k] = getResult("Major", k);
		Minor_Array[k] = getResult("Minor", k);
		RatioAxis_Array[k] = Major_Array[k]/Minor_Array[k];
	}
	close("Temp");close("Results");
	//Others Information
	Table.rename("Final_Results", "Results");
	selectWindow(ImageNameNoExt+"_Resliced_"+i+1);
	for (k = 0; k < roiManager("count"); k++) {
		roiManager("select",k);
		run("Measure");
	}
	for (k = 0; k < roiManager("count"); k++) {
		setResult("Major", k+NumFrames*i, Major_Array[k]);
		setResult("Minor", k+NumFrames*i, Minor_Array[k]);
		setResult("Axis ratio", k+NumFrames*i, RatioAxis_Array[k]);
	}
	for (l = 0; l < NumFrames; l++) {
		print(l+NumFrames*i);
		Ellipse[l+NumFrames*i] = getResult("Area",l+NumFrames*i);
		Length[l+NumFrames*i] = l*0.32;
		Perimeter[l+NumFrames*i] = getResult("Perim.",l+NumFrames*i);
		Angle[l+NumFrames*i] = asin(sin(getResult("Angle",l+NumFrames*i)/180*2*PI));
	}
	roiManager("deselect");roiManager("delete");
 	selectWindow("Results");
 	
 	IJ.renameResults("Final_Results");
 	
}
//Graph Area Ellipse
//CLear Previous Results Reset measurements with Ellipse information
saveAs("Table", Dir1+"\\Final_Results.csv");
//DrawGraph
for (i = 0; i < TubeNumber; i++) {
	open(Dir1+"\\Final_Results.csv");
	selectWindow("Final_Results.csv");
	Table.deleteRows(0, NumFrames*i);
	Table.deleteRows(NumFrames, NumFrames*(nResults));
	saveAs("Table", Dir1+"\\Results_"+i+".csv");
	close("Results_"+i+".csv");
	close("Final_Results.csv");
}
DrawGraph("Tube Area", "Length (µm)", "Tube Area (µm²)", Length, Ellipse,TubeNumber,NumFrames,PathSave);
DrawGraph("Tube Perimeter", "Length (µm)", "Tube Perimeter(µm)", Length, Perimeter,TubeNumber,NumFrames,PathSave);
DrawGraph("Tube Angle", "Length (µm)", "Orientation (°)", Length, Angle,TubeNumber,NumFrames,PathSave);


//Clean all but "Actin" and "Nucleus"

list = getList("window.titles"); ImList = getList("image.titles");
AllWinList = Array.concat(list,ImList);//Array.show(AllWinList);
     for (i=0; i<AllWinList.length; i++){ 
     winame = AllWinList[i]; 
     	selectWindow(winame); 
     	if (winame != "Actin" && winame != "Nucleus" ){
     		 run("Close"); 
     	}
     
     } 

 
//MergeData ==> %Volume
		run("Set Measurements...", "area mean perimeter fit area_fraction redirect=None decimal=3");
		//1: Combine/Sum Binary Actin+nucleus
		selectWindow("Actin");
		run("Make Binary", "method=Default background=Default calculate black");
		selectWindow("Nucleus");
		run("Make Binary", "method=Default background=Default calculate black");
		imageCalculator("Add create stack", "Actin","Nucleus");
		selectWindow("Result of Actin");rename("Sum");
			//Remove Outliers
		run("Remove Outliers...", "radius=5 threshold=50 which=Bright stack");
		//2: Individualise each tube
		getDimensions(width, height, channels, slices, frames);
			//First Canal
		SplitTube(TubeNumber,"Sum",ImageNameNoExt);
		//3: %Area
			//Load ROI of Tube1
			AreaRatio = newArray(NumFrames*TubeNumber);
		for (k= 0; k < TubeNumber; k++) {
			roiManager("open", Dir1+"\\"+ImageNameNoExt+"RoiTube"+k+1+".zip");roiManager("deselect");
			selectWindow(ImageNameNoExt+"_Resliced_"+k+1);run("Select All");
			run("Reslice [/]...", "output="+depth+" start=Top avoid");
			
			for (i = 0; i < roiManager("count"); i++) {
				roiManager("select", i);
				run("Measure");
				AreaRatio[i+NumFrames*k] = getResult("%Area", i+NumFrames*k);
			}
			roiManager("deselect");roiManager("delete");
		}
		
		//4: PLot vs length
		DrawGraph("Tube %Area", "Length (µm)", "Tube % Area", Length, AreaRatio,TubeNumber,NumFrames,PathSave);

		 		
 		run("Close All");selectWindow("Results");run("Close");
}
waitForUser("Is it done ?", "Yes, it is! ");

//Draw Graph Function
function DrawGraph(Title, Horiz_Axis_Name, Vert_Axis_Name,Horiz_Axis_Data,Vert_Axis_Data,TubeNumber,NumFrames,Path){
 	Plot.create(Title, Horiz_Axis_Name, Vert_Axis_Name);
 	for (i = 0; i < TubeNumber; i++) {
 		Plot.setColor(colorArray[i]);
 		Plot.add("line", Horiz_Axis_Data, Array.slice(Vert_Axis_Data, i * NumFrames, (i+1)*NumFrames));
 	}
 	Plot.show();
 	Plot.setLimitsToFit()
 	selectWindow(Title);
	save(PathSave+"_"+Title);
 		}

//Fit Ellipse function
function CanalEllipse(){
setBatchMode(true);
run("Create Selection");
run("Convex Hull");
run("Fit Ellipse");
roiManager("add");
setBatchMode(false);
}

function SplitTube(TubeNumber,Name,ImageNameNoExt){
	getDimensions(width, height, channels, slices, frames);
			//First Canal
			for (i = 1; i <= TubeNumber; i++) {
				selectWindow(Name);
				makeRectangle((i-1)*width/TubeNumber, 0, width/TubeNumber, height);
				run("Duplicate...", "title="+ImageNameNoExt+"_Resliced_"+i+" duplicate");
				
			}
}
