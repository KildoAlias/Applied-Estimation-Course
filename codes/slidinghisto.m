% IN: En frame fr�n filmen 
% UT:  (Min tanke) delsteg,matris med 1or p� likely pixels (objektet), och 0 p� background
% alternativt koordinater till center av cluster d�r bollen t�nks vara


function Max_likelihood = slidinghisto(image,histwidth,histheight,threshold)

histheight=histheight-1;
histwidth=histwidth-1;

[H,W]=size(image);
indx=1;
for i=1:H-histheight
   
    for j=1:W-histwidth
        
        [counts, binlocations]=imhist(image(i:histheight+i,j:histwidth+j));
        
        
       % figure()
        %imhist(image(i:histheight+i,j:histwidth+j));
        
        %figure()
        
        %subplot(1,2,1)
        %imshow(image(i:histheight+i,j:histwidth+j));
        %subplot(1,2,2)
        %imshow(image)
        
        count{i,j}=counts;  %counts �r antal pixlar av varje f�rg 
        bins{i,j}=binlocations; %varje bin motsvarar en shade av gr�
        im=image(i:histheight+i,j:histwidth+j);
        %dunno men ide h�r nedan, se testcode.m f�r tankeng�ngen kring thresholdet, threhold ish 80:
        %skapar matris med likeihood v�rden 1 om de �r svart, 0 om de �r
        % vitt, sparar sedan varje delbit av bilden f�r att kunna ta max 
         im(im<=threshold)=1;
         im(im>threshold)=0;
       
        im_parts_likelihood(:,:,indx)=im; %verkar som ngt blir fel h�r :s
                                          % testa typ A=[1,2,3;4,5,6;7,8,9]
                                          % A(A<=3)=1
                                          %A(A>3)=0
                                          %s� funkar de som man vill,
                                          %fattar ej riktigt vrf de blir
                                          %som de blir.
        
        %alt spara i cell
        %   imparts{i,j}=im; 
        
        
        indx=indx+1;
        
    end
    
end

Max_likelihood=max(im_parts_likelihood,[],3); 
               
                                            % Ta ut den med mest 1or= 
                                             %=b�sta delbilden av bollen, 
                                             % har ej hittat hur vi f�r
                                             % index i 3d matrisen, samt n�r vi har index
                                             % m�ste vi associatea till
                                             % original bilden, dvs vart i
                                             % original bilden denna
                                             % delbild �r located,
                                             % d�refter ber�kna alla
                                             % masscentrum f�r dessa, dvs
                                             % mittenpixeln och leverara ut
                                             % de till de filter vi vill
                                             % ha. Detta �r iaf min tanke?
                                           
                                      




end