﻿<%

' File: json.asp
' 
' AXE(ASP Xtreme Evolution) json file media.
' 
' License:
' 
' This file is part of ASP Xtreme Evolution.
' Copyright (C) 2007-2012 Fabio Zendhi Nagao
' 
' ASP Xtreme Evolution is free software: you can redistribute it and/or modify
' it under the terms of the GNU Lesser General Public License as published by
' the Free Software Foundation, either version 3 of the License, or
' (at your option) any later version.
' 
' ASP Xtreme Evolution is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU Lesser General Public License for more details.
' 
' You should have received a copy of the GNU Lesser General Public License
' along with ASP Xtreme Evolution. If not, see <http://www.gnu.org/licenses/>.



' Class: XSession_Media_Json
' 
' This class enables XSession to persist data using json files.
' 
' About:
' 
'     - Written by Fabio Zendhi Nagao <http://zend.lojcomm.com.br> @ Nov 2010
' 
class XSession_Media_Json' implements XSession_Interface
    
    ' --[ Interface ]-----------------------------------------------------------
    public Interface
    
    ' --[ Media definition ]--------------------------------------------------
    
    ' Property: classType
    ' 
    ' Class type.
    ' 
    ' Contains:
    ' 
    '   (string) - type
    ' 
    public classType

    ' Property: classVersion
    ' 
    ' Class version.
    ' 
    ' Contains:
    ' 
    '   (string) - version
    ' 
    public classVersion
    
    ' Property: folder
    ' 
    ' File System physical folder
    ' 
    ' Contains:
    ' 
    '     (string) - file system physical folder
    ' 
    public folder
    
    ' Property: encoding
    ' 
    ' Text encoding
    ' 
    ' Contains:
    ' 
    '     (Stream.charset) - text encoding. Defaults to UTF-8
    ' 
    public encoding
    
    private sub Class_initialize()
        classType    = typename(Me)
        classVersion = "1.0.0.0"
        
        set Interface = new XSession_Interface
        set Interface.Implementation = Me
        if(not Interface.check) then
            Err.raise 17, "Evolved AXE runtime error", strsubstitute( _
                "Can't perform requested operation. '{0}' is a bad interface implementation of '{1}'", _
                array(classType, typename(Interface)) _
            )
        end if
        
        encoding = "UTF-8"
    end sub
    
    private sub Class_terminate()
        set Interface.Implementation = nothing
        set Interface = nothing
    end sub
    
    ' Function: load
    ' 
    ' Returns the serialized XSession from the json file.
    ' 
    ' Parameters:
    ' 
    '     (string) - XSession unique id
    ' 
    ' Returns:
    ' 
    '     (string) - XSession serialized content
    ' 
    public function load(id)
        if(varType(folder) = vbEmpty) then
            Err.raise 5, "Evolved AXE runtime error", strsubstitute( _
                "Invalid procedure call or argument. '{0}' property 'folder' isn't defined", _
                array(classType) _
            )
        end if
        
        dim Fso : set Fso = Server.createObject("Scripting.FileSystemObject")
        dim filePath : filePath = strsubstitute( "{0}{1}.json", array( folder, mid(id, 2, 36) ) )
        
        if( Fso.fileExists(filePath) ) then
            dim Stream : set Stream = Server.createObject("ADODB.Stream")
            with Stream
                .type = adTypeText
                .mode = adModeReadWrite
                .charset = "UTF-8"
                .open()
                
                .loadFromFile(filePath)
                .position = 0
                load = .readText()
                
                .close()
            end with
            set Stream = nothing
        else
            load = "{}"
        end if
        
        set Fso = nothing
    end function
    
    ' Subroutine: save
    ' 
    ' Media writing routine.
    ' 
    ' Parameters:
    ' 
    '     (string) - XSession unique id
    '     (string) - XSession serialized content
    ' 
    public sub save(id, content)
        if(varType(folder) = vbEmpty) then
            Err.raise 5, "Evolved AXE runtime error", strsubstitute( _
                "Invalid procedure call or argument. '{0}' property 'folder' isn't defined", _
                array(classType) _
            )
        end if
        
        dim Stream : set Stream = Server.createObject("ADODB.Stream")
        with Stream
            .charset = encoding
            .type = adTypeText
            .mode = adModeReadWrite
            .open()
            
            call .writeText(content, adWriteLine)
            .setEOS()
            .position = 0
            call .saveToFile( strsubstitute( "{0}{1}.json", array( folder, mid(id, 2, 36) ) ), adSaveCreateOverWrite )
            
            Stream.close()
        end with
        set Stream = nothing
    end sub
    
end class

%>
