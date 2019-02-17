classdef JPEGProcessObj < handle
    
    properties (GetAccess=public)
        
        DCTcoefficients
        quantTables
        
        % Color Space RGB, needed for the PBC-CGC conversion
        R
        G
        B
        
        % Save of PBC values of R, G and B
        PBCr
        PBCg
        PBCb
    end
    
    % ... methods
    methods (Access=private)
        %==================================================================
        % Constructor
        %==================================================================
        function JPEGImage=JPEGProcessObj(DCTcoefficients, quantTables)
            % Initialization of class fileds
            JPEGImage.DCTcoefficients   =  DCTcoefficients;
            JPEGImage.quantTables       =  quantTables;
            JPEGImage.R = 0;
            JPEGImage.G = 0;
            JPEGImage.B = 0;
        end
        
        %==================================================================
        % Quantization
        %==================================================================
        function Quantization(JPEGImage)
            JPEGImage.DCTcoefficients{1} = round(JPEGImage.DCTcoefficients{1}./JPEGImage.quantTables{1});
            JPEGImage.DCTcoefficients{2} = round(JPEGImage.DCTcoefficients{2}./JPEGImage.quantTables{2});
            JPEGImage.DCTcoefficients{3} = round(JPEGImage.DCTcoefficients{3}./JPEGImage.quantTables{2});
        end
        
        function Inverse_Quantization(JPEGImage)
            JPEGImage.DCTcoefficients{1} = JPEGImage.DCTcoefficients{1}.*JPEGImage.quantTables{1};
            JPEGImage.DCTcoefficients{2} = JPEGImage.DCTcoefficients{2}.*JPEGImage.quantTables{2};
            JPEGImage.DCTcoefficients{3} = JPEGImage.DCTcoefficients{3}.*JPEGImage.quantTables{2};
        end
        %==================================================================
        % Discrete Cosine Transform
        %==================================================================
        function DCT(JPEGImage)
            JPEGImage.DCTcoefficients{1}  = dct2(JPEGImage.DCTcoefficients{1});
            JPEGImage.DCTcoefficients{2}  = dct2(JPEGImage.DCTcoefficients{2});
            JPEGImage.DCTcoefficients{3}  = dct2(JPEGImage.DCTcoefficients{3});
        end
        
        function Inverse_DCT(JPEGImage)
            JPEGImage.DCTcoefficients{1}  = idct2(JPEGImage.DCTcoefficients{1});
            JPEGImage.DCTcoefficients{2}  = idct2(JPEGImage.DCTcoefficients{2});
            JPEGImage.DCTcoefficients{3}  = idct2(JPEGImage.DCTcoefficients{3});
        end
        
        %==================================================================
        % Color space conversion (YCbCr to RGB and vice versa)
        %==================================================================
        function YCbCr_to_RGB(JPEGImage)
            JPEGImage.R = round(JPEGImage.DCTcoefficients{1}  + 1.402*(JPEGImage.DCTcoefficients{3} - 128));
            JPEGImage.G = round(JPEGImage.DCTcoefficients{1}  - 0.34414*(JPEGImage.DCTcoefficients{2} - 128) - 0.71414*(JPEGImage.DCTcoefficients{3} - 128));
            JPEGImage.B = round(JPEGImage.DCTcoefficients{1}  + 1.772*(JPEGImage.DCTcoefficients{2} - 128));
        end
        
        function RGB_to_YCbCr(JPEGImage)
            JPEGImage.DCTcoefficients{1}  =  0.299*JPEGImage.R   + 0.587*JPEGImage.G    + 0.114*JPEGImage.B;
            JPEGImage.DCTcoefficients{2}  = -0.1687*JPEGImage.R  - 0.3313*JPEGImage.G   + 0.5*JPEGImage.B + 128;
            JPEGImage.DCTcoefficients{3}  =  0.5*JPEGImage.R     - 0.4187*JPEGImage.G   - 0.0813*JPEGImage.B + 128;
        end
        
        %==================================================================
        % Shifting
        %==================================================================
        function Positive_Shift(JPEGImage)
            JPEGImage.DCTcoefficients{1}   = round(JPEGImage.DCTcoefficients{1}) + 128;
            JPEGImage.DCTcoefficients{2}   = round(JPEGImage.DCTcoefficients{2}) + 128;
            JPEGImage.DCTcoefficients{3}   = round(JPEGImage.DCTcoefficients{3}) + 128;
        end
        
        function Negative_Shift(JPEGImage)
            JPEGImage.DCTcoefficients{1}   = JPEGImage.DCTcoefficients{1} - 128;
            JPEGImage.DCTcoefficients{2}   = JPEGImage.DCTcoefficients{2} - 128;
            JPEGImage.DCTcoefficients{3}   = JPEGImage.DCTcoefficients{3} - 128;
        end
    end
    
    methods (Access=public)
        %==================================================================
        % Main Functions
        %==================================================================
        function Decompressor_JPEG(JPEGImage)
            Inverse_Quantization(JPEGImage);
            Inverse_DCT(JPEGImage);
            Positive_Shift(JPEGImage);
            YCbCr_to_RGB(JPEGImage);
            
            % Save of the values R, G and B
            JPEGImage.PBCr = JPEGImage.R;
            JPEGImage.PBCg = JPEGImage.G;
            JPEGImage.PBCb = JPEGImage.B;
        end
        
        function Compressor_JPEG(JPEGImage)
            RGB_to_YCbCr(JPEGImage);
            Negative_Shift(JPEGImage);
            DCT(JEPGImage);
            Quantization(JPEGImage);
        end
    end
end