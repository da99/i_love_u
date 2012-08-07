



# Implementation

## Code Blocks

Three options: 

      
    /* 1) As file: */
    Roger is described from: file:///some/file.
    
    /* 2) As indented: */
    Roger is described as:

      Question is a Objectivist.
      Objectivist is unknown.

    /* 3) As bookends: */
    Bio is described as:
    Block:
    
      /*  
        The indentation of Block:/end! matters to Uni_Lang.
        This was a design choice to force you to write 
        readable code for humans.
      */
      Question is:
      Block:
        An Objectivist.
        A Crime-fighter.
      end!
      
    end!


## Text Blocks

Two options:

    /* 1) As file: */
    Roger is a Block from: file:///some/file.

    /* 2) As block with inner blocks escaped: */
    Text:

      The following must be escaped:
      \\Text:
        \\Text:
    \\end! # This line is ignored despite the indentation.
      \\!!end

      Code blocks are ignored, but not their ends:
      Block:
      Block:
          \\end!
      \\end!

    # Indentation of the final end! matters.
    end!


