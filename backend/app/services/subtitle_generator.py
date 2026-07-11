import math

class SubtitleGeneratorService:
    def generate_ass(self, segments: list, output_path: str):
        """
        Generates an Advanced SubStation Alpha (.ass) file from Groq whisper segments.
        Adds dynamic pop-in animations.
        """
        ass_header = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
WrapStyle: 1

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,80,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,4,0,2,20,20,250,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(ass_header)
            
            for segment in segments:
                start_sec = float(segment.get('start', 0))
                end_sec = float(segment.get('end', 0))
                text = segment.get('text', '').strip()
                
                # Split text into chunks of max 3 words for 9:16 format
                words = text.split()
                if not words:
                    continue
                    
                words_per_chunk = 3
                duration = end_sec - start_sec
                time_per_word = duration / len(words)
                
                for i in range(0, len(words), words_per_chunk):
                    chunk_words = words[i:i + words_per_chunk]
                    chunk_text = ' '.join(chunk_words)
                    
                    chunk_start = start_sec + (i * time_per_word)
                    chunk_end = start_sec + ((i + len(chunk_words)) * time_per_word)
                    
                    # Highlight if text matches specific conditions (mocking emotional highlight)
                    # Real app would use the isHighlight flag from frontend or AI
                    is_highlight = segment.get('isHighlight', False) or any(w.lower() in ['wow', 'crazy', 'insane', 'shocking'] for w in chunk_words)
                    
                    color_tag = "{\\c&H00FFFF&}" if is_highlight else "" # Yellow in BGR (ASS uses BBGGRR)
                    
                    start_time_str = self._format_ass_time(chunk_start)
                    end_time_str = self._format_ass_time(chunk_end)
                    
                    # Add scale pop animation \t(0,200,\fscx120\fscy120) \t(200,400,\fscx100\fscy100)
                    # This creates a bounce effect
                    animated_text = f"{color_tag}{{\\fscx80\\fscy80\\t(0,100,\\fscx110\\fscy110)\\t(100,200,\\fscx100\\fscy100)}}{chunk_text}"
                    
                    line = f"Dialogue: 0,{start_time_str},{end_time_str},Default,,0,0,0,,{animated_text}\n"
                    f.write(line)

    def _format_ass_time(self, seconds: float) -> str:
        """Format seconds to ASS time format: H:MM:SS.cs"""
        h = int(seconds // 3600)
        m = int((seconds % 3600) // 60)
        s = int(seconds % 60)
        cs = int(round((seconds - int(seconds)) * 100))
        if cs == 100:
            s += 1
            cs = 0
            if s == 60:
                m += 1
                s = 0
        return f"{h:d}:{m:02d}:{s:02d}.{cs:02d}"

subtitle_generator = SubtitleGeneratorService()
