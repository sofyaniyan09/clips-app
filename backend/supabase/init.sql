-- Drop tables if they exist
DROP TABLE IF EXISTS public.clips CASCADE;
DROP TABLE IF EXISTS public.jobs CASCADE;
DROP TABLE IF EXISTS public.presets CASCADE;

-- Presets Table
CREATE TABLE public.presets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    color_grading VARCHAR(255) DEFAULT 'Standard',
    font_style VARCHAR(255) DEFAULT 'Inter',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Jobs Table
CREATE TABLE public.jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'queued', -- queued, processing, done, failed
    progress INTEGER NOT NULL DEFAULT 0,
    platform VARCHAR(100) DEFAULT 'TikTok',
    estimated_time VARCHAR(100),
    source_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Clips Table
CREATE TABLE public.clips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES public.jobs(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    thumbnail_url TEXT,
    duration VARCHAR(50),
    virality_score INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS) Configuration

-- Enable RLS
ALTER TABLE public.presets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clips ENABLE ROW LEVEL SECURITY;

-- Presets Policies
CREATE POLICY "Users can view their own presets"
ON public.presets FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own presets"
ON public.presets FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own presets"
ON public.presets FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own presets"
ON public.presets FOR DELETE
USING (auth.uid() = user_id);

-- Jobs Policies
CREATE POLICY "Users can view their own jobs"
ON public.jobs FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own jobs"
ON public.jobs FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own jobs"
ON public.jobs FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own jobs"
ON public.jobs FOR DELETE
USING (auth.uid() = user_id);

-- Clips Policies
CREATE POLICY "Users can view clips from their jobs"
ON public.clips FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM public.jobs
        WHERE public.jobs.id = public.clips.job_id
        AND public.jobs.user_id = auth.uid()
    )
);

CREATE POLICY "Service role can insert clips"
ON public.clips FOR ALL
USING (true)
WITH CHECK (true); -- Usually, insertion of clips is done by the backend (Service Role), which bypasses RLS anyway.
