import numpy as np
cimport numpy as cnp
cimport stdlib
cimport python_exc

cdef extern from "alsa/asoundlib.h":
        ctypedef enum snd_pcm_stream_t:
                SND_PCM_STREAM_PLAYBACK
                SND_PCM_STREAM_CAPTURE
        ctypedef enum snd_pcm_access_t :
                SND_PCM_ACCESS_MMAP_INTERLEAVED
                SND_PCM_ACCESS_MMAP_NONINTERLEAVED
                SND_PCM_ACCESS_MMAP_COMPLEX
                SND_PCM_ACCESS_RW_INTERLEAVED
                SND_PCM_ACCESS_RW_NONINTERLEAVED
        ctypedef enum snd_pcm_format_t :
                SND_PCM_FORMAT_UNKNOWN
                SND_PCM_FORMAT_S8
                SND_PCM_FORMAT_U8
                SND_PCM_FORMAT_S16_LE
                SND_PCM_FORMAT_S16_BE
                SND_PCM_FORMAT_U16_LE
                SND_PCM_FORMAT_U16_BE
                SND_PCM_FORMAT_S24_LE
                SND_PCM_FORMAT_S24_BE
                SND_PCM_FORMAT_U24_LE
                SND_PCM_FORMAT_U24_BE
                SND_PCM_FORMAT_S32_LE
                SND_PCM_FORMAT_S32_BE
                SND_PCM_FORMAT_U32_LE
                SND_PCM_FORMAT_U32_BE
                SND_PCM_FORMAT_FLOAT_LE
                SND_PCM_FORMAT_FLOAT_BE
                SND_PCM_FORMAT_FLOAT64_LE
                SND_PCM_FORMAT_FLOAT64_BE
                SND_PCM_FORMAT_IEC958_SUBFRAME_LE
                SND_PCM_FORMAT_IEC958_SUBFRAME_BE
                SND_PCM_FORMAT_MU_LAW
                SND_PCM_FORMAT_A_LAW
                SND_PCM_FORMAT_IMA_ADPCM
                SND_PCM_FORMAT_MPEG
                SND_PCM_FORMAT_GSM
                SND_PCM_FORMAT_SPECIAL
                SND_PCM_FORMAT_S24_3LE
                SND_PCM_FORMAT_S24_3BE
                SND_PCM_FORMAT_U24_3LE
                SND_PCM_FORMAT_U24_3BE
                SND_PCM_FORMAT_S20_3LE
                SND_PCM_FORMAT_S20_3BE
                SND_PCM_FORMAT_U20_3LE
                SND_PCM_FORMAT_U20_3BE
                SND_PCM_FORMAT_S18_3LE
                SND_PCM_FORMAT_S18_3BE
                SND_PCM_FORMAT_U18_3LE
                SND_PCM_FORMAT_U18_3BE
                SND_PCM_FORMAT_S16
                SND_PCM_FORMAT_U16
                SND_PCM_FORMAT_S24
                SND_PCM_FORMAT_U24
                SND_PCM_FORMAT_S32
                SND_PCM_FORMAT_U32
                SND_PCM_FORMAT_FLOAT
                SND_PCM_FORMAT_FLOAT64
                SND_PCM_FORMAT_IEC958_SUBFRAME

        ctypedef struct snd_pcm_t
        ctypedef struct snd_pcm_hw_params_t
        ctypedef struct snd_pcm_sw_params_t
        #ctypedef struct snd_pcm_access_t
        #ctypedef struct snd_pcm_format_t

        # XXX: how to make sure the typedef is OK ?
        ctypedef unsigned long snd_pcm_uframes_t

        int snd_pcm_open(snd_pcm_t **, char*, int, int)
        int snd_pcm_close(snd_pcm_t *)
        int snd_pcm_drain(snd_pcm_t *)

        int snd_pcm_hw_params_alloca(snd_pcm_hw_params_t **)
        int snd_pcm_hw_params_any(snd_pcm_t*, snd_pcm_hw_params_t *)
        int snd_pcm_hw_params(snd_pcm_t*, snd_pcm_hw_params_t *)

        int snd_pcm_hw_params_set_access(snd_pcm_t*, snd_pcm_hw_params_t *,
                                         snd_pcm_access_t)
        int snd_pcm_hw_params_set_format(snd_pcm_t*, snd_pcm_hw_params_t *,
                                         snd_pcm_format_t)
        int snd_pcm_hw_params_set_channels(snd_pcm_t*, snd_pcm_hw_params_t *,
                                         unsigned int)
        int snd_pcm_hw_params_set_rate_near(snd_pcm_t*, snd_pcm_hw_params_t *,
                                         unsigned int *val, int dir)
        int snd_pcm_hw_params_set_buffer_time_near(snd_pcm_t*, snd_pcm_hw_params_t *,
                                         unsigned int *val, int dir)
        int snd_pcm_hw_params_set_period_time_near(snd_pcm_t*, snd_pcm_hw_params_t *,
                                         unsigned int *val, int dir)
        int snd_pcm_hw_params_get_period_size(snd_pcm_hw_params_t *,
                                         unsigned int *val, int dir)
        int snd_pcm_hw_params_get_buffer_size(snd_pcm_hw_params_t *,
                                         unsigned int *val)

        int snd_pcm_sw_params_alloca(snd_pcm_sw_params_t **)
        int snd_pcm_sw_params(snd_pcm_t*, snd_pcm_sw_params_t *)
        int snd_pcm_sw_params_current(snd_pcm_t *, snd_pcm_sw_params_t *)
        int snd_pcm_sw_params_set_start_threshold(snd_pcm_t *,
                        snd_pcm_sw_params_t *, snd_pcm_uframes_t)
        int snd_pcm_sw_params_set_avail_min(snd_pcm_t *,
                        snd_pcm_sw_params_t *, snd_pcm_uframes_t)
        #int snd_pcm_sw_params_set_avail_min(snd_pcm_t *, snd_pcm_sw_params_t *)

        int snd_pcm_writei(snd_pcm_t *, void*, snd_pcm_uframes_t)

        char* snd_strerror(int error)

        int snd_card_next(int *icard)
        int snd_card_get_name(int icard, char** name)
        int snd_card_get_hints(int icard, char* id, void*** hints)

        char* snd_asoundlib_version()

cdef int BUFFER_TIME  = 500000
cdef int PERIOD_TIME  = 0

cdef extern from "Python.h":
        object PyString_FromStringAndSize(char *v, int len)

class AlsaException(Exception):
        pass

def asoundlib_version():
        return snd_asoundlib_version()

def card_indexes():
        """Returns a list containing index of cards recognized by alsa."""
        cdef int icur = -1

        cards = []
        while 1:
                st = snd_card_next(&icur)
                if st < 0:
                        raise AlsaException("Could not get next card")
                if icur < 0:
                        break
                cards.append(icur)
        return tuple(cards)
def card_name(index):
        """Get the name of the card corresponding to the given index."""
        cdef char* sptr
        st = snd_card_get_name(index, &sptr)
        if st < 0:
                raise AlsaException("Error while getting card name %d: alsa error "\
                                    "was %s" % (index, snd_strerror(st)))
        else:
                cardname = PyString_FromStringAndSize(sptr, len(sptr))
                stdlib.free(sptr)
        return cardname

cdef struct format_info:
        # number of channels
        int nchannel
        # Rate (samples/s -> Hz)
        int rate
        # Bits per sample
        int nbits
        # Byte format
        int byte_fmt

cdef class AlsaDevice:
        cdef snd_pcm_t *handle
        def __init__(AlsaDevice self, unsigned rate=48000, int nchannels=1):
                cdef int st
                cdef unsigned int psize, bsize
                cdef format_info info

                info.rate = rate
                info.nchannel = nchannels

                self.handle = <snd_pcm_t*>0
                st = snd_pcm_open(&self.handle, "default", SND_PCM_STREAM_PLAYBACK, 0)
                if st < 0:
                        raise AlsaException("Fail opening 'default'")

                set_hw_params(self.handle, info, &psize, &bsize)
                print "Period size is", psize, ", Buffer size is", bsize

                set_sw_params(self.handle, psize, bsize)

        def play(AlsaDevice self, cnp.ndarray input):
                cdef cnp.ndarray[cnp.int16_t, ndim=2] tx
                cdef int nr, i, nc, counts
                cdef int bufsize = 1024
                cdef int err

                if not input.ndim == 2:
                        raise ValueError("Only rank 2 for now")
                else:
                        nc = input.shape[1]
                        if not nc == 2:
                                raise ValueError("Only stereo for now")

                tx = np.empty((bufsize, nc), dtype=np.int16)
                nr = input.size / nc / bufsize

                counts = 0
                for i in range(nr):
                        err = python_exc.PyErr_CheckSignals()
                        if err != 0:
                                if python_exc.PyErr_ExceptionMatches(KeyboardInterrupt):
                                        raise KeyboardInterrupt()
                        tx = (32568 * input[i * bufsize:i * bufsize + bufsize, :]).astype(np.int16)
                        st = snd_pcm_writei(self.handle, <void*>tx.data, bufsize)
                        if st < 0:
                                raise AlsaException("Error in writei")

        def __dealloc__(AlsaDevice self):
                if self.handle:
                        snd_pcm_close(self.handle)

cdef set_hw_params(snd_pcm_t *hdl, format_info info, unsigned int* period_size, unsigned int *buffer_size):
        cdef unsigned int nchannels, buftime, pertime, samplerate
        cdef snd_pcm_hw_params_t *params
        cdef int st
        cdef snd_pcm_access_t access
        cdef snd_pcm_format_t format

        access = SND_PCM_ACCESS_RW_INTERLEAVED
        buftime = BUFFER_TIME
        pertime = PERIOD_TIME

        nchannels = info.nchannel
        samplerate = info.rate
        format = SND_PCM_FORMAT_S16_LE

        snd_pcm_hw_params_alloca(&params)
        st = snd_pcm_hw_params_any(hdl, params)
        if st < 0:
                raise AlsaException("Error in _any")

        st = snd_pcm_hw_params_set_access(hdl, params, access)
        if st < 0:
                raise AlsaException("Error in _set_access")

        st = snd_pcm_hw_params_set_format(hdl, params, format)
        if st < 0:
                raise AlsaException("Error in _set_format")

        st = snd_pcm_hw_params_set_channels(hdl, params, nchannels)
        if st < 0:
                raise AlsaException("Error in _set_channels")

        st = snd_pcm_hw_params_set_rate_near(hdl, params, &samplerate, 0)
        if st < 0:
                raise AlsaException("Error in _set_rate_near")

        st = snd_pcm_hw_params_set_buffer_time_near(hdl, params, &buftime, 0)
        if st < 0:
                raise AlsaException("Error in _set_buffer_near")

        st = snd_pcm_hw_params_set_period_time_near(hdl, params, &pertime, 0)
        if st < 0:
                raise AlsaException("Error in _set_period_time_near")

        st = snd_pcm_hw_params(hdl, params)
        if st < 0:
                raise AlsaException("Error in applying hw params")

        st = snd_pcm_hw_params_get_period_size(params, period_size, 0)
        if st < 0:
                raise AlsaException("Error in get_period_sizse")

        st = snd_pcm_hw_params_get_buffer_size(params, buffer_size)
        if st < 0:
                raise AlsaException("Error in get_buffer_sizse")

cdef set_sw_params(snd_pcm_t *hdl, unsigned int period_size, unsigned int buffer_size):
        cdef snd_pcm_sw_params_t *params

        snd_pcm_sw_params_alloca(&params)

        st = snd_pcm_sw_params_current(hdl, params)
        if st < 0:
                raise AlsaException("Error in _current")

        st = snd_pcm_sw_params_set_start_threshold(hdl, params, period_size)
        if st < 0:
                raise AlsaException("Error in _set_start_threshold")

        st = snd_pcm_sw_params_set_avail_min(hdl, params, period_size)
        if st < 0:
                raise AlsaException("Error in _set_avail_min")

        st = snd_pcm_sw_params(hdl, params)
        if st < 0:
                raise AlsaException("Error in applying sw params")